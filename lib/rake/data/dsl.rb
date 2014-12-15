module Rake
  module DSL
    # Load a file from the internet

    def url( dest, source )
      file dest do
        puts "Loading #{source}"
        if !File.exists?( dest )
          mkdir_p dest.to_s.pathmap( "%d" )
          sh "curl -L '#{source}' > #{dest}"
        end
      end
    end

    # Make a rule that transforms the data from the source directory
    # into the data directory
    #
    # example:
    # data_rule ".csv", ".wikipedia.html", block
    # will generate "processed/table.csv" from the file "source/table.wikipedia.html"
    #
    def data_rule( dest_ext, source_ext, &block )
      renaming = lambda do |x|
        x.sub( /^processed/, 'source' ).sub( /#{dest_ext}$/, source_ext )
      end

      rule dest_ext => renaming do |dest|
        yield dest
      end
    end


    # Parse an HTML file into CSV
    def parse_html( dest, source, &parser )
      require 'nokogiri'
      require 'csv'

      file dest => source do
        puts "Parsing #{source} -> #{dest}"
        mkdir_p dest.to_s.pathmap( "%d" )

        html = Nokogiri.parse( File.read( source ) )
        CSV.open( dest.to_s, "wb" ) do |csv|
          parser.call( html, csv )
        end
      end
    end

    # Loop over a file and yield the block for each line
    # If name ends with .csv, parse the csv and yield each line
    def file_loop( name, source )
      task name => source do
        if source =~ /.csv$/
          first_row = nil
          CSV.open( source ).each do |line|
            first_row ||= line
            values = Hash.new do |h,k|
              idx = first_row.index(k)
              if !idx
                raise "Couldn't find column named #{k}"
              end
              h[k] = line[idx]
            end
            yield line, values, first_row
          end
        else
          File.readlines( source ).each do |line|
            yield line
          end
        end
      end
    end

    # Take only a subset of a file
    # slice( dest, source, 1, 10 ) -> Lines 1 to 10
    # slice( dest, source, 3, 6 ) -> Lines 4 - 6
    def slice( dest, source, beg_line, end_line )
      file dest => source do
        sh "sed -n '#{beg_line},#{end_line}p' < #{source} > #{dest}"
      end
    end

    # Command grep patterns
    # Regex here is a string that will be passed to grep
    def filter( dest, source, regex, inverse = false )
      file dest => source do
        sh "grep #{inverse ? '-v' : ''} #{regex} #{source} > #{dest}"
      end
    end

    ##
    # Dedup the input lines
    def dedup dest, src
      file dest => src do
        mkdir_p dest.to_s.pathmap( "%d" )
        sh "uniq #{src} > #{dest}"
      end
    end
  end
end