require 'pp'
require 'rubygems'
# require 'ruby-debug'


require File.dirname(__FILE__) + '/figure'
module BattleCalculator
  
  ACCURACY = 0.001
  
  def self.to_hit attacker, defender
    case
    when attacker.ws < (defender.ws/2.to_f)
      1 / 3.to_f
    when ((attacker.ws >= (defender.ws/2.to_f)) and (attacker.ws <= defender.ws))
      1 / 2.to_f
    when attacker.ws > defender.ws
      2 / 3.to_f
    end
  end

  def self.to_wound attacker, defender
    difference = attacker.s - defender.t
    number_of_successful_values = 3 + difference
    number_of_successful_values = 5 if number_of_successful_values > 5
    number_of_successful_values = 1 if number_of_successful_values < 1
    number_of_successful_values / 6.to_f
  end

  def self.to_armor_save attacker, defender
    armor_save_modifier = attacker.s - 3
    normalized_armor_save = (defender.armor_save < 1) ? 1 : defender.armor_save

    modified_armor_save = normalized_armor_save + armor_save_modifier

    modified_armor_save = 7 if modified_armor_save > 7
    modified_armor_save = 2 if modified_armor_save < 2
    
    (7 - modified_armor_save) / 6.to_f
  end

  def self.to_ward_save defender
    normalized_ward_save = 2 if defender.ward_save < 2
    normalized_ward_save = 7 if defender.ward_save > 7
    normalized_ward_save ||= defender.ward_save
    (7 - normalized_ward_save) / 6.to_f
  end

  def self.to_wound_on_single_attack attacker, defender
    to_hit = self::to_hit(attacker, defender)
    to_wound = self::to_wound(attacker, defender)
    to_armor_save = self::to_armor_save(attacker, defender)
    to_ward_save = self::to_ward_save(defender)
    
    to_hit_and_wound = to_hit * to_wound
    to_save = to_armor_save + ((1 - to_armor_save) * to_ward_save)
    
    to_hit_and_wound * (1-to_save)
  end

  def self.to_wound_for_all_attacks attacker, defender
    attacker.a*self::to_wound_on_single_attack(attacker, defender)
  end

  # options currently takes only 1 key: :exact
  # if :exact => true, then kills will be counted as fails if too many
  # wounds are dealt.
  def self.to_kill attacker, defender
    chance_to_wound = self::to_wound_on_single_attack attacker, defender
    perform_kill attacker.a, defender.w, chance_to_wound, 1, :exact => false
  end

  def self.to_score_exact_wounds attacker, defender, target_wounds
    chance_to_wound = self::to_wound_on_single_attack attacker, defender
    perform_kill attacker.a, target_wounds, chance_to_wound, 1, :exact => true
  end
  # chance_to_wound - precalculated chance that the attacker has to
  # wound the defender remaining_chance - the portion of 100% that
  # this recursive iteration is working with In order for the kill to
  # succeed, 2 hashes (wounds) are needed. We keep spending from our
  # 100% until either attacks or wounds or remaining chance run out

  # [-----|#####]
  # [--|##|--|##]
  #    [-#|-#]
  def self.perform_kill attacks, wounds, chance_to_wound, remaining_chance, options
    # no chance of killing the defender
    return 0 if (attacks < wounds) or (attacks < 0) or (remaining_chance == 0)

    if options.has_key?(:exact) and options[:exact]
      # nailed the target! bank it!
      return remaining_chance if wounds == 0 and attacks == 0
    else
      # dead! bank it!
      return remaining_chance if wounds == 0
    end
    
    # not dead yet!

    # split the remaining chance into parts in ratio to the chance to wound
    remaining_chance_for_wound_branch = chance_to_wound*remaining_chance
    remaining_chance_for_fail_branch = remaining_chance-remaining_chance_for_wound_branch
    
    # use an attack, take a wound
    wound_branch = self::perform_kill attacks-1, wounds-1, chance_to_wound, remaining_chance_for_wound_branch, options

    # use an attack, but fail to wound
    fail_branch = self::perform_kill attacks-1, wounds, chance_to_wound, remaining_chance_for_fail_branch, options
    

    # aggregate the probability of killing the opponent via each branch.
    wound_branch + fail_branch
  end

  def self.to_win_duel attacker, defender, number_of_rounds
    raise "equal initiative not implemented" if attacker.i == defender.i

    # lead has higher initiative than follow
    lead, follow = [attacker, defender].sort_by(&:i)

    results = self::perform_duel follow, lead, number_of_rounds*2

    # investigate why this needs to be done.
    results = (lead == attacker) ? self::invert_duel_probabilities(results) : results
    {:attacker => results[:lead_wins], :defender => results[:follow_wins]}
  end

  def self.perform_duel_with_equal_initiative lead, follow, number_of_rounds, remaining_chance=1
    return {:both_die => remaining_chance, :lead_wins => 0, :follow_wins => 0} if lead.w == 0 and follow.w == 0
    return {:both_die => 0, :lead_wins => remaining_chance, :follow_wins => 0} if follow.w == 0
    return {:both_die => 0, :lead_wins => 0, :follow_wins => remaining_chance} if lead.w == 0
    return {:both_die => 0, :lead_wins => 0, :follow_wins => 0} if (number_of_rounds == 0) or (remaining_chance <= ACCURACY)
  end

  def self.perform_duel lead, follow, number_of_rounds, remaining_chance=1
    # puts number_of_rounds
    # puts lead.inspect
    return {:lead_wins => remaining_chance, :follow_wins => 0} if follow.w == 0
    return {:lead_wins => 0, :follow_wins => remaining_chance} if lead.w == 0
    return {:lead_wins => 0, :follow_wins => 0} if (number_of_rounds == 0) or (remaining_chance <= ACCURACY)

    eventual_kill_probabilities = []
    follow.w.times do |i|
      non_kill_probability = BattleCalculator::to_score_exact_wounds lead, follow, i

      lead_clone = lead.clone
      follow_clone = follow.clone      
      follow_clone.w -= i

      # Let the other figure attack by swapping lead and follow and
      # inverting the return value.  (this is very similar to a
      # minimax algorithm) eg. If it returns .3 chance for follow to
      # kill lead, then eventual_kill_probability = .7.
      results = perform_duel(follow_clone, lead_clone, number_of_rounds-1, remaining_chance*non_kill_probability)
      eventual_kill_probabilities << self::invert_duel_probabilities(results)
    end

    immediate_kill_probability = BattleCalculator::to_kill(lead, follow)*remaining_chance

    # aggregate all kill results
    {
      :lead_wins => 
      ( immediate_kill_probability + eventual_kill_probabilities.inject(0) { |sum, x| sum + x[:lead_wins] } ), 
      :follow_wins => 
      ( eventual_kill_probabilities.inject(0) {|sum, x| sum + x[:follow_wins]} )
    }
   end

  private
  
  def self.invert_duel_probabilities probability_hash
    {:lead_wins => probability_hash[:follow_wins], :follow_wins => probability_hash[:lead_wins]}
  end


end
