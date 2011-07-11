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

    describe "prepare_data" do
      before(:each) do
        @obj1 = GoogleChart::Column.new(%w[one two], [[1,2], [3,4]])
        @obj2 = GoogleChart::Column.new(%w[one two], [%w[1 2], %w[3 4]])
        @obj3 = GoogleChart::Column.new(%w[one two], [[1,2], [3,4], [5,6]])
      end

      it "should prepare columns according to the column names" do
        prepped = @obj1.prepare_data
        prepped.should =~ /'number', 'one'/
        prepped.should =~ /'number', 'two'/

        prepped = @obj2.prepare_data

        prepped.should =~ /'string', 'one'/
        prepped.should =~ /'string', 'two'/
      end

      it "should add the appropriate number of rows" do
        prepped = @obj1.prepare_data
        prepped.should =~ /data\.addRows\(2\);/
        
        prepped = @obj3.prepare_data
        prepped.should =~ /data\.addRows\(3\);/
      end

      it "should set a value for each item in the set" do
        prepped = @obj1.prepare_data
        @obj1.set.each_with_index do |row, i|
          row.each_with_index do |item, j|
            prepped.should =~ /data\.setValue\(#{i}, #{j}, #{item}/
          end
        end

        prepped = @obj2.prepare_data
        @obj2.set.each_with_index do |row, i|
          row.each_with_index do |item, j|
            prepped.should =~ /data\.setValue\(#{i}, #{j}, '#{item}'/
          end
        end
      end
    end
  end
end
