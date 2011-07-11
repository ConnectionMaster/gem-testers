require 'spec_helper'
require 'chart'

describe GoogleChart::Column do
  describe "initialization" do
    it "should DTRT" do
      proc { GoogleChart::Column.new(%w[one two three], [%w[1 2], %w[3 4]]) }.should_not raise_error
      proc { GoogleChart::Column.new(1, [%w[1 2], %w[3 4]]) }.should raise_error
      proc { GoogleChart::Column.new(%w[one two three], [1,2]) }.should raise_error
    end
  end

  describe "method output" do
    before(:each) do
      @obj = GoogleChart::Column.new(%w[one two], [%w[1 2], %w[3 4]])
    end

    it "should have a fixed preamble" do
      @obj.preamble.strip.should == %q!google.load("visualization", "1", {packages:["corechart"]});!
    end

    describe "draw_chart" do
      it "should properly interpolate" do
        @obj.draw_chart('Frobnitz', 'Foobar', 'divvy').should == <<-EOF
        var chart = new google.visualization.ColumnChart(document.getElementById('divvy'));
        chart.draw(data, {width: 400, height: 240, title: 'Frobnitz',
                          hAxis: {title: 'Foobar', titleTextStyle: {color: 'red'}}
                         });
        EOF
      end
    end
  end
end
