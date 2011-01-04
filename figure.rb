require File.dirname(__FILE__) + '/calculator'

class Figure
  attr_accessor :i, :ws, :s, :t, :a, :w, :armor_save, :ward_save

  def initialize attributes={}
    @ws = attributes[:ws].to_i
    @s = attributes[:s].to_i
    @t = attributes[:t].to_i
    @a = attributes[:a].to_i
    @w = attributes[:w].to_i
    @i = attributes[:i].to_i
    [@ws, @s, @t, @a, @w, @i].each do |attribute|
      attribute = 10 if attribute > 10
    end
    @armor_save = attributes[:armor_save].to_i
    @armor_save ||= 7
    @ward_save = attributes[:ward_save].to_i
    @ward_save ||= 7
  end

  def to_win_vs other, number_of_rounds
    results = BattleCalculator::to_win_duel self, other, number_of_rounds
    results[:attacker]
  end

  # "score" = getting through all saves in addition to landing the wound.
  def to_score_wound_vs other
    BattleCalculator::to_wound_on_single_attack self, other
  end
end
