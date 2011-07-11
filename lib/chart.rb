module GoogleChart
  class Column
    # http://code.google.com/apis/chart/interactive/docs/gallery/columnchart.html
    #
    # pretty simple right now; a config object in the future might be necessary
    # if we add multiple charts on one page or whatever. JFDI.
    #

    attr_reader :set
    attr_reader :column_names

    def initialize(column_names, set)
      unless column_names.kind_of?(Array)
        raise ArgumentError, "please provide an array of column names."
      end

      unless set.kind_of?(Array) and set.all? { |x| x.kind_of?(Array) }
        raise ArgumentError, "please use an array of array."
      end

      unless variable_name
        raise ArgumentError, "damnit. really?"
      end

      @set           = set
      @column_names  = column_names
    end

    def preamble
      return <<-EOF
        google.load("visualization", "1", {packages:["corechart"]});
      EOF
    end

    def prepare_data 
      javascript <<-EOF
        var data = new google.visualization.DataTable();
      EOF

      column_names.each do |column_name|
        javascript += "data.addColumn('string', '#{column_name.gsub(/'/, "\\'")}');\n"
      end

      javascript += "data.addRows(#{set.size});\n"

      set.each_with_index do |row, i|
        row.each_with_index do |item, j|
          javascript += "data.setValue(#{i}, #{j},"
          case item
          when Numeric
            javascript += item + ");\n"
          else
            javascript += "'#{item}');\n"
          end
        end
      end

      return javascript
    end

    def draw_chart(title, haxis_title, chart_div='chart_div')
      return <<-EOF
        var chart = new google.visualization.ColumnChart(document.getElementById('#{chart_div}'));
        chart.draw(data, {width: 400, height: 240, title: '#{title}',
                          hAxis: {title: '#{haxis_title}', titleTextStyle: {color: 'red'}}
                         });
      EOF
    end
  end
end
