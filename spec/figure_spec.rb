require File.dirname(__FILE__) + '/../figure'

describe Figure do
  describe "#initialize should set defaults for" do
    it "armor and ward save" do
      f = Figure.new
      f.armor_save.should == 7
      f.ward_save.should == 7
    end
  end

  describe "#initialize should set initial values via attributes hash for" do
    it "s, t, ws, armor_save, and ward_save" do
      f = Figure.new :i => '3', :a => '2', :w => '3', :s => '2', :t => '3', :ws => '4', :armor_save => '5', :ward_save => '6'
      f.s.should == 2
      f.t.should == 3
      f.ws.should == 4
      f.a.should == 2
      f.w.should == 3
      f.armor_save.should == 5
      f.ward_save.should == 6
    end
  end

  describe "#to_win_vs should calculate the probability of winning vs" do
    before :all do
      @one = Figure.new :ws => 3, :i => 4, :s => 3, :t => 3, :a => 1, :w => 1, :armor_save => 7, :ward_save => 7
      @two = Figure.new :ws => 3, :i => 3, :s => 3, :t => 3, :a => 1, :w => 1, :armor_save => 7, :ward_save => 7
    end
    
    it "opponent one" do
      puts @one.to_score_wound_vs @two
      @one.to_win_vs(@two, 10).should == 1
    end
    
  end
end
