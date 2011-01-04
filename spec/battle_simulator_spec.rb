require File.dirname(__FILE__) + '/../battle_simulator'
require File.dirname(__FILE__) + '/../figure'

describe BattleSimulator do
  
  before :all do
    @valid_figure_attributes = {:s => 3, :t => 3, :ws => 4, :a => 1, :armor_save => 5}
    @one = Figure.new @valid_figure_attributes
    @two = Figure.new @valid_figure_attributes
  end

  it "should take two figures to initiate battle" do
    sim = BattleSimulator.new @one, @two
    sim.is_a?(BattleSimulator).should be_true
    sim.unit_a.should be one
    sim.unit_b.should be two
  end

  it "should simulate a fight and output each sides probability of winning" do
    
  end
  
end
