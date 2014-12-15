require 'rake/data/dsl'
require 'csv'

##
# Find the unique values of a column in a csv file
def unique_values dest, src, columns
  file dest => src do |task|
    mkdir_p task.to_s.pathmap( "%d" )
    values = {}
    col_names = columns.split( /,/ )
    col_nums = nil
    CSV.open( task.source ).each do |row|
      if col_nums.nil?
        col_nums = {}
        col_names.each do |n|
          col_nums[n] = row.index n
          raise "Couldn't find column #{column} in #{src}" unless col_nums[n]
        end
      else
        key = col_names.collect { |x| row[col_nums[x]] }.join( "," )
        values[key] = true
      end
    end

    File.open( task.to_s, "wb" ) do |out|
      out.puts columns
      values.keys.each do |val|
        out.puts val
      end
    end
  end
end

##
# Sum the column values
# Optionally group by columns
# total_column "data/sample_counts.csv", "data/babynames.csv", "CNT", "ETHCTY,GNDR"
def total_column dest, src, sum_column, group_by = nil
  file dest => src do |task|
    puts "Totalling #{sum_column} from #{src}, group_by #{group_by}"
    mkdir_p task.to_s.pathmap( "%d" )
    values = {}
    group_by = group_by.split( /,/ ) if group_by
    col_nums = nil
    value_col = nil
    CSV.open( task.source ).each do |row|
      if value_col.nil?
        value_col = row.index sum_column
        raise "Couldn't find column #{sum_column} in #{src}" unless value_col

        if group_by
          col_nums = {}
          group_by.each do |n|
            col_nums[n] = row.index n
            raise "Couldn't find column #{column} in #{src}" unless col_nums[n]
          end
        end
      else
        if group_by
          key = group_by.collect { |x| row[col_nums[x]] }.join( "," )
        else
          key = sum_column
        end
        values[key] ||= 0
        values[key] += row[value_col].to_f
      end
    end

    File.open( task.to_s, "wb" ) do |out|
      if group_by
        out.puts [group_by + [sum_column]].join( "," )
      else
        out.puts "#{sum_column},TOTAL"
      end
      values.keys.each do |val|
        out.puts "#{val},#{values[val]}"
      end
    end
  end
end

def csv_transform dest, source, &block
  task dest => source do
    CSV.open( dest, "wb" ) do |out|
      CSV.open( source ).each do |row|
        yield row, out
      end
    end
  end
end

# total = csv_read_val( "data/scaled_babynames.csv", "CNT", { "ETHCTY" => in_row[2], "GNDR" => in_row[1] } )

def csv_read_val( src, col, select = nil )
  header = nil
  CSV.open( src ).each do |row|
    if header == nil
      header = row
    else
      if !select
        return row[header.index(col)]
      else
        matches = select.keys.collect do |sel|
          row[header.index(sel)] == select[sel]
        end
        if !matches.index( false )
          return row[header.index(col)]
        end
      end
    end
  end
  nil
end