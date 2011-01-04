class BattleSimulator
  
  attr_accessor :unit_a, :unit_b

  def initialize a, b
    @unit_a = a
    @unit_b = b
  end

  def fight
    raise "equal initiative not implemented" if @unit_a.i == @unit_b.i
    lead = (@unit_a.i > @unit_b.i) ? @unit_a : @unit_b
    follow = (@unit_a.i < @unit_b.i) ? @unit_a : @unit_b
    
    chance_to_wound_for_lead = BattleCalculator::to_wound_on_single_attack lead, follow
    chance_to_wound_for_follow = BattleCalculator::to_wound_on_single_attack follow, lead

    chance_lead_wins = perform_fight lead, follow, chance_to_wound_for_lead, chance_to_wound_for_follow
    
  end

  private
  
  def perform_fight lead, follow, lead_attacks, lead_wounds, follow_attacks, follow_wounds, chance_to_wound_for_lead, chance_to_wound_for_follow, remaining_chance=1
    return 0 if (lead_wounds == 0) or (remaining_chance == 0)
    return remaining_chance if follow_wounds == 0

    eventual_kill_probabilities = []
    (follow_wounds - 1).times do |i|
      non_kill_probability = BattleCalculator::to_score_exact_wounds lead, follow, i
      follow.w -= i
      # Let the other figure attack by swapping lead and follow and
      # inverting the return value.  (this is very similar to a
      # minimax algorithm) eg. If it returns .3 chance for follow to
      # kill lead, then eventual_kill_probability = .7.
      eventual_kill_probabilities << ( 1 - perform_fight(follow, lead, chance_to_wound_for_follow, chance_to_wound_for_lead, remaining_chance*non_kill_probability) ) # todo
    end

    immediate_kill_probability = BattleCalculator::to_kill lead, follow
    # aggregate all kill results
    immediate_kill_probability + eventual_kill_probabilities.inject(0){|sum, x| sum + x}
  end
  
end
