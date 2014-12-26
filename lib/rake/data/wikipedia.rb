require 'rake/data/dsl'

# elevation_extremes_by_country

def wikipedia_list( list_name )
  url "source/#{list_name}.wikipedia.html", "http://en.wikipedia.org/wiki/List_of_#{list_name}"
  "processed/#{list_name}.csv"
end

def wikipedia_lists_of( list_name )
  url "source/#{list_name}.wikipedia.html", "http://en.wikipedia.org/wiki/Lists_of_#{list_name}"
  "processed/#{list_name}.csv"
end

data_rule ".csv", ".wikipedia.html" do |dest|
  parse_html dest, dest.source do |html,csv|
    header_columns = nil
    column_has_link = []
    data = []
    html.css( "table.wikitable tr" ).each do |row|
      if header_columns.nil?
        header_columns = table_columns( row, "th" )
        header_columns = nil if header_columns.size == 0
      else
        columns = table_columns( row, "td" )
        columns.each_with_index do |c,idx|
          column_has_link[idx] = true if c.is_a? Array
        end
        data << columns
      end
    end

    # require 'pp'
    # pp data

    csv << row_data_with_links( header_columns, column_has_link, true )
    data.each do |row|
      csv << row_data_with_links( row, column_has_link )
    end
  end
end

def table_columns( row, selector )
  columns = row.css( selector ).collect do |column|
    # Find the text column
    text = column.children.text
    if text
      text = text.gsub( /^\s*/, "" ).gsub( /\s*$/, "" )
    end
    # select do |x|
    #   x.name == "text"
    # end.collect do |x|
    #   x.content.gsub( /^\s*/, "" ).gsub( /\s*$/, "" )
    # end.join( " " )

    link = column.css( "a" ).first
    if link
      href = link['href']
      link_text = link.children.select do |x|
        x.name == "text"
      end.collect do |x|
        x.content.gsub( /^\s*/, "" ).gsub( /\s*$/, "" )
      end.join( " " )

      link_text = link_text.gsub( /^\s*/, "" ).gsub( /\s*$/, "" )

      text = [link_text,href]
    end

    text
  end
end

def row_data_with_links( data_row, column_has_link, header_link = false)
  row = []
  data_row.each_with_index do |column,idx|
    val = column.is_a?( Array )? column[0] : column
    row << val
    if column_has_link[idx]
      if header_link
        row << "#{column} link"
      else
        row << (column.is_a?( Array )? column[1] : "")
      end
    end
  end
  row
end