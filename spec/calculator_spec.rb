require File.dirname(__FILE__) + '/../calculator'

describe BattleCalculator do
  before do
    @error_margin = 0.00000001
    @attacker = Figure.new
    @defender = Figure.new
  end

  describe "#to_hit should properly calculate hit percentage" do
    
    it "when attacker's weapon skill is higher" do
      @attacker.ws = 5
      @defender.ws = 4
      BattleCalculator::to_hit(@attacker, @defender).should == (2/3.to_f)  
    end
    
    it "when attacker's weapon skill is equal" do
      @attacker.ws = 3
      @defender.ws = 3
      BattleCalculator::to_hit(@attacker, @defender).should == 0.5
    end
    
    it "when attacker's weapon skill is lower but not by more than double" do
      @attacker.ws = 2
      @defender.ws = 3
      BattleCalculator::to_hit(@attacker, @defender).should == 0.5
    end
    
    it "when attacker's weapon skill is lower by more than double" do
      @attacker.ws = 1
      @defender.ws = 3
      BattleCalculator::to_hit(@attacker, @defender).should == (1/3.to_f)
    end
    
    it "when attacker's weapon skill is lower by more than double in a higher range of numbers" do
      @attacker.ws = 4
      @defender.ws = 10
      BattleCalculator::to_hit(@attacker, @defender).should == (1/3.to_f)
    end
    
    it "when attacker's weapon skill is exactly half" do
      @attacker.ws = 5
      @defender.ws = 10
      BattleCalculator::to_hit(@attacker, @defender).should == 0.5
    end
    
    it "when attacker's weapon skill is just below half in a higher range of numbers" do
      @attacker.ws = 4
      @defender.ws = 9  
      BattleCalculator::to_hit(@attacker, @defender).should == (1/3.to_f)
    end
  end

  describe "#to_wound should properly calculate wound percentage for" do

    it "equal strength and toughness" do
      @attacker.s = 4
      @defender.t = 4
      BattleCalculator::to_wound(@attacker, @defender).should == 0.5
    end

    it "+1 strength over toughness" do
      @attacker.s = 4
      @defender.t = 3
      BattleCalculator::to_wound(@attacker, @defender).should == (2/3.to_f)
    end

    it "+2 strength over toughness" do
      @attacker.s = 5
      @defender.t = 3
      BattleCalculator::to_wound(@attacker, @defender).should == (5/6.to_f)
    end

    # Limit is 2+ to wound, regardless
    it "+3 strength over toughness" do
      @attacker.s = 6
      @defender.t = 3
      BattleCalculator::to_wound(@attacker, @defender).should == (5/6.to_f)
    end

    it "+200 strength over toughness" do
      @attacker.s = 203
      @defender.t = 3
      BattleCalculator::to_wound(@attacker, @defender).should == (5/6.to_f)
    end

    it "+1 toughness over strength" do
      @attacker.s = 2
      @defender.t = 3
      BattleCalculator::to_wound(@attacker, @defender).should == (1/3.to_f)
    end  

    it "+2 toughness over strength" do
      @attacker.s = 2
      @defender.t = 4
      BattleCalculator::to_wound(@attacker, @defender).should == (1/6.to_f)
    end

    # Worst is 6+ to wound, ever
    it "+3 toughness over strength" do
      @attacker.s = 3
      @defender.t = 6
      BattleCalculator::to_wound(@attacker, @defender).should == (1/6.to_f)
    end

    it "+300 toughness over strength" do
      @attacker.s = 2
      @defender.t = 302
      BattleCalculator::to_wound(@attacker, @defender).should == (1/6.to_f)
    end
  end

  describe "#armor_save should properly calculate save percentage for" do

    it "1+ armor and s5" do
      @attacker.s = 5
      @defender.armor_save = 1
      BattleCalculator::to_armor_save(@attacker, @defender).should == (2/3.to_f)
    end

    it "1+ armor and s3" do
      @attacker.s = 3
      @defender.armor_save = 1
      BattleCalculator::to_armor_save(@attacker, @defender).should == (5/6.to_f)
    end

    it "1+ armor and s1" do
      @attacker.s = 1
      @defender.armor_save = 1
      BattleCalculator::to_armor_save(@attacker, @defender).should == (5/6.to_f)
    end

    it "1+ armor and s7" do
      @attacker.s = 7
      @defender.armor_save = 1
      BattleCalculator::to_armor_save(@attacker, @defender).should == (1/3.to_f)
    end

    it "5+ armor and s5" do
      @attacker.s = 5
      @defender.armor_save = 5
      BattleCalculator::to_armor_save(@attacker, @defender).should == 0
    end

    # Should normalize to 1+ armor
    it "0+ armor and s5" do
      @attacker.s = 5
      @defender.armor_save = 1
      BattleCalculator::to_armor_save(@attacker, @defender).should == (2/3.to_f)
    end
  end

  describe "#to_ward_save should properly calculate ward save percentage for" do

    5.times do |i|
      it "#{i}+ save" do
        save = i + 2
        @defender.ward_save = save
        BattleCalculator::to_ward_save(@defender).should == (7 - save) / 6.to_f
      end
    end

    it "8+ save" do
      @defender.ward_save = 8
      BattleCalculator::to_ward_save(@defender).should == 0
    end

    # Normalize to 2+, always
    it "0+ save" do
      @defender.ward_save = 0
      BattleCalculator::to_ward_save(@defender).should == (5/6.to_f)
    end
  end

  # describe "#to_wound_on_single_attack should calculate the probability that an attack will wound the target with" do
    
  #   it "1+ armor, toughness 5, attacking with strength 3, equal weaponskill" do
  #     @attacker.s = 3
  #     @attacker.ws = 5
  #     @defender.armor_save = 1
  #     @defender.t = 5
  #     @defender.ws = 5
  #     BattleCalculator::to_wound_on_single_attack(@attacker, @defender).should be_within(@error_margin).of(1/72.to_f)
  #   end

  #   it "5+ ward 5+ armor, toughness 3, attacking with strength 3, equal weaponskill" do
  #     @attacker.s = 3
  #     @attacker.ws = 3
  #     @defender.armor_save = 5
  #     @defender.ward_save = 5
  #     @defender.t = 3
  #     @defender.ws = 3
  #     BattleCalculator::to_wound_on_single_attack(@attacker, @defender).should == (1/9.to_f)
  #   end

  #   it "7+ ward 7+ armor, toughness 3, attacking with strength 3, equal weaponskill" do
  #     @attacker.s = 3
  #     @attacker.ws = 3
  #     @defender.armor_save = 7
  #     @defender.ward_save = 7
  #     @defender.t = 3
  #     @defender.ws = 3
  #     BattleCalculator::to_wound_on_single_attack(@attacker, @defender).should == (0.25)
  #   end
    
  #   it "-1+ ward -2+ armor, toughness 3, attacking with strength 3, equal weaponskill" do
  #     @attacker.s = 3
  #     @attacker.ws = 3
  #     @defender.armor_save = -1
  #     @defender.ward_save = -2
  #     @defender.t = 3
  #     @defender.ws = 3
  #     BattleCalculator::to_wound_on_single_attack(@attacker, @defender).should be_within(@error_margin).of(1/144.to_f)
  #   end

  # end

  describe "#to_wound_for_all_attacks should calculate proper chance to hit for" do
    it "set one" do
      @attacker.s = 3
      @attacker.ws = 3
      @attacker.a = 3
      @defender.armor_save = 4
      @defender.ward_save = 6
      @defender.t = 3
      @defender.ws = 4
      
      BattleCalculator::to_wound_for_all_attacks(@attacker, @defender).should == (5/16.to_f)
    end

    it "set two" do
      @attacker.a = 3

      @attacker.s = 5
      @defender.t = 3

      @attacker.ws = 3
      @defender.ws = 4

      @defender.armor_save = 4
      @defender.ward_save = 6

      BattleCalculator::to_wound_for_all_attacks(@attacker, @defender).should == (125/144.to_f)
    end


    
  end

  describe "#to_score_exact_wounds should calculate the probability of doing precisely the given number of wounds in" do
    
    it "set one" do
      @attacker = Figure.new :s => 5, :t => 5, :ws => 4, :i => 4, :a => 2, :w => 3, :armor_save => 3
      @defender = Figure.new :s => 3, :t => 3, :ws => 4, :i => 3, :a => 3, :w => 2, :armor_save => 3

      BattleCalculator::to_score_exact_wounds(@attacker, @defender, 2).should be_within(@error_margin).of(25/324.to_f)
    end

    it "set two" do
      @attacker = Figure.new :s => 5, :t => 5, :ws => 4, :i => 4, :a => 2, :w => 3, :armor_save => 3
      @defender = Figure.new :s => 3, :t => 3, :ws => 4, :i => 3, :a => 3, :w => 1, :armor_save => 3
      # to_hit = 1/2 5/6 2/3 = 5/18
      # left branch = 5/18*13/18 = 65/324
      # right branch = 13/18*5/18 = 65/324
      # right branch + left branch = 130/324
      BattleCalculator::to_score_exact_wounds(@attacker, @defender, 1).should be_within(@error_margin).of(130/324.to_f)
    end

    it "set three, 0 target wounds, 0 attacks" do
      @attacker = Figure.new :s => 5, :t => 5, :ws => 4, :i => 4, :a => 0, :w => 3, :armor_save => 3
      @defender = Figure.new :s => 3, :t => 3, :ws => 4, :i => 3, :a => 3, :w => 1, :armor_save => 3

      BattleCalculator::to_score_exact_wounds(@attacker, @defender, 0).should == 1
    end

    it "set four, 0 target wounds, 1 attack" do
      @attacker = Figure.new :s => 5, :t => 5, :ws => 4, :i => 4, :a => 1, :w => 3, :armor_save => 3
      @defender = Figure.new :s => 3, :t => 3, :ws => 4, :i => 3, :a => 3, :w => 1, :armor_save => 3

      BattleCalculator::to_score_exact_wounds(@attacker, @defender, 0).should be_within(@error_margin).of(13/18.to_f)
    end

    it "set five" do
      @attacker = Figure.new :ws => 3, :i => 4, :s => 3, :t => 3, :a => 1, :w => 1, :armor_save => 7, :ward_save => 7
      @defender = Figure.new :ws => 3, :i => 3, :s => 3, :t => 3, :a => 1, :w => 1, :armor_save => 7, :ward_save => 7


      BattleCalculator::to_score_exact_wounds(@attacker, @defender, 0).should be_within(@error_margin).of(3/4.to_f)
    end

  end

  describe "#to_kill should calculate how likely a kill will occur for defenders current wounds in" do

    it "set one" do
      @attacker = Figure.new :s => 5, :t => 5, :ws => 4, :i => 4, :a => 2, :w => 3, :armor_save => 3
      @defender = Figure.new :s => 3, :t => 3, :ws => 4, :i => 3, :a => 3, :w => 2, :armor_save => 3

      BattleCalculator::to_kill(@attacker, @defender).should be_within(@error_margin).of(25/324.to_f)
    end


    it "set two" do
      @attacker = Figure.new :s => 5, :t => 5, :ws => 4, :i => 4, :a => 2, :w => 3, :armor_save => 3
      @defender = Figure.new :s => 3, :t => 3, :ws => 4, :i => 3, :a => 3, :w => 1, :armor_save => 3
      #1/2 5/6 2/3 10/36 => 90/324 + 65/324 = 155/324
      BattleCalculator::to_kill(@attacker, @defender).should be_within(@error_margin).of(155/324.to_f)
    end

    it "set three" do
      @attacker = Figure.new :s => 5, :t => 5, :ws => 4, :i => 4, :a => 3, :w => 3, :armor_save => 3
      @defender = Figure.new :s => 3, :t => 3, :ws => 4, :i => 3, :a => 3, :w => 1, :armor_save => 3
      #1/2 5/6 2/3 = 5/18 => 
      # 5/18 + (65/324|13/18*5/18) + 845/5832|(13/18*65/324)
      # 5/18 + 2015/5832
      # 3635/5832
      BattleCalculator::to_kill(@attacker, @defender).should be_within(@error_margin).of(3635/5832.to_f)
    end

    it "when attacks are fewer than target wounds" do
      @attacker = Figure.new :s => 5, :t => 5, :ws => 4, :i => 4, :a => 1, :w => 3, :armor_save => 3
      @defender = Figure.new :s => 3, :t => 3, :ws => 4, :i => 3, :a => 3, :w => 2, :armor_save => 3

      BattleCalculator::to_kill(@attacker, @defender).should == 0
    end

  end


  describe "#to_win_duel should calculate the probability of the attacker winning the duel" do
    before :all do
      @one = Figure.new :ws => 3, :i => 4, :s => 3, :t => 3, :a => 1, :w => 1, :armor_save => 7, :ward_save => 7
      @two = Figure.new :ws => 3, :i => 3, :s => 3, :t => 3, :a => 1, :w => 1, :armor_save => 7, :ward_save => 7
    end
    
    it "opponent one" do
      # 1/4 to_score_wound
      
      # 1/4 to kill on first round
      # 3/4*1/4 to die on the first round
      # 3/4*3/4*1/4 to kill on second round
      # 3/4*3/4*3/4*1/4 to die on the second round
      # all other results = tie

      # 1/4 + 3/4*3/4*1/4 = attacker probability
      # 3/4*(attacker probability) = defender probability
      BattleCalculator::to_win_duel(@one, @two, 2).should == {:attacker => 25/64.to_f, :defender => 75/256.to_f}
    end

    it "swapped with opponent one" do
      BattleCalculator::to_win_duel(@two, @one, 2).should == {:attacker => 75/256.to_f, :defender => 25/64.to_f}
    end

    it "opponent two" do
      @one.t = 5
      # 1/4 to_score_wound for @one
      # 1/12 for @two
      
      # 1/4 to kill on first round
      # 3/4*1/12 to die on the first round
      # 3/4*3/4*1/4 to kill on second round
      # 3/4*3/4*3/4*1/12 to die on the second round
      # all other results = tie

      # 1/4 + 3/4*11/12*1/4 = attacker probability
      # 3/4*(1/12 + 11/12*3/4*1/12) = defender probability
      BattleCalculator::to_win_duel(@one, @two, 2).should == {:attacker => 27/64.to_f, :defender => 27/256.to_f}
    end

    it "against multiple wounds" do
      @two.w = 2
      @two.t = 5

      # one to_score two = 1/12
      # two to_score one = 1/4

      # 1/12 score one wound (2 wounds to kill)
      # 1/4 two kills one first round
      
      # 1/12*3/4*1/12 one kills two second round
      # 11/12*3/4*1/12 one scores first wound on second round
      
      # 1/12*3/4*11/12*1/4 two kills one second round

      # one: 1/12*3/4*1/12 = 1/192
      # two: 1/4 + 1/12*3/4*11/12*1/4 + 11/12*3/4*12/12*1/4 = 335/768

      results = BattleCalculator::to_win_duel(@one, @two, 2)

      results[:attacker].should be_within(@error_margin).of(1/192.to_f)
      results[:defender].should be_within(@error_margin).of(335/768.to_f)
    end

    it "when intiatives are equal" do
      # 1/4 to_score_wound
      
      # 1/4 to kill on first round
      # 1/4 to die on the first round
      # 1/4*1/4 to kill and die on first round

      # 3/4*3/4*1/4 to kill on second round
      # 3/4*3/4*1/4 to die on the second round
      # 3/4*3/4*1/4*1/4 to kill and die on second round

      # 1/4 + 3/4*3/4*1/4 = attacker probability
      # attacker probability = defender probability
      # 1/4*(attacker probability) = both probability
      BattleCalculator::to_win_duel(@one, @two, 2).should == {:attacker => 25/64.to_f, :defender => 75/256.to_f, :both => 1}
    end
  end
  
end


# BattleCalculator::calculate unit_one unit_two #=> BattleStatistics.new
