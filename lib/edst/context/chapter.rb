require 'edst/context/base'

module EDST
  module Context
    module ChapterFormatter
      def label_id(str)
        str.downcase.gsub(/[ :]/, "_").gsub(/_+/, '_')
      end
    end
    module ChapterStructs
      Paragraph = Struct.new(:string)
      Head = Struct.new(:contents)
      Body = Struct.new(:contents)
      Foot = Struct.new(:contents)
      Content = Struct.new(:name, :contents)
      Part = Struct.new(:name, :id)
      Parts = Struct.new(:contents)
      Character = Struct.new(:name, :state)
      Characters = Struct.new(:contents)
      Dialogue = Struct.new(:speaker, :string)
      Tag = Struct.new(:key, :value)
      Label = Struct.new(:name, :id)
      Comment = Struct.new(:string)

      @@character_states = {
        '$' => :add,
        '=' => :pesist,
        '!' => :remove,
        '*' => :special
      }
    end
    module ChapterParser
      include ChapterFormatter
      include ChapterStructs

      def parse_characters_body(tokens, **options)
        data = []
        tokens.each do |(k, v)|
          if k == 'tag'
            data << Character.new(v['value'], @@character_states[v['key']])
          else
            STDERR.puts "Invalid character body token: #{k}" if options[:verbose]
          end
        end
        data
      end

      def parse_parts_body(tokens, **options)
        data = []
        tokens.each do |(k, v)|
          if k == 'label'
            data << Part.new(v['value'], label_id(v['value']))
          else
            STDERR.puts "Invalid parts body token: #{k}" if options[:verbose]
          end
        end
        data
      end

      def parse_body(tokens, **options)
        data = []
        next_is_block = nil
        tokens.each do |k, v|
          if k == 'tag' && v['attributes']['type'] == 'block'
            next_is_block = v['key']
          end
          case k
          when 'div'
            if next_is_block
              case next_is_block
              when 'plan', 'notes'
                # drop the plan from the render
              when 'change_log'
                # drop the change log from the render
                #html.concat(container do |subhtml|
                #  subhtml << h3('Change Log')
                #  subhtml << '<ol class=\'parts\'>'
                #  subhtml.concat(parse_body(v['children']))
                #  subhtml << '</ol>'
                #end)
              when 'parts'
                data.push(Parts.new(parse_parts_body v['children']))
              when 'characters'
                data.push(Characters.new(parse_characters_body v['children']))
              when 'head'
                data.push(Head.new(parse_body v['children']))
              when 'body'
                data.push(Body.new(parse_body v['children']))
              when 'foot'
                data.push(Foot.new(parse_body v['children']))
              else
                data.push(Content.new(next_is_block, parse_body(v['children'])))
              end
            else
              data.concat(parse_body(v['children']))
            end
          when 'tag'
            data.push(Tag.new(v['key'], v['value']))
          when 'p'
            data.push(Paragraph.new(v['value']))
          when 'label'
            data.push(Label.new(v['value'], label_id(v['value'])))
          when 'dialogue'
            data.push(Dialogue.new(v['key'], v['value']))
          when 'comment'
            data.push(Comment.new(v['value']))
          else
            STDERR.puts "unhandled type #{k}" if options[:verbose]
          end
        end
        data
      end

      def parse(*args, &block)
        parse_body(*args, &block)
      end

      extend self
    end
    class Chapter < Base
      include ChapterFormatter
      include ChapterStructs

      attr_accessor :meta
      attr_accessor :navigation
      attr_accessor :chapters

      attr_reader :id
      attr_reader :title
      attr_reader :sub_title
      attr_reader :chapter_id
      attr_reader :head
      attr_reader :body
      attr_reader :characters
      attr_reader :parts
      attr_reader :contents
      attr_reader :narrator
      attr_reader :head_contents
      attr_reader :body_contents
      attr_reader :foot_contents

      def initialize(options = {})
        super
        @meta = nil
        @navigation = nil
        @chapters = nil
        @inline = false

        @id = ''
        @title = ''
        @sub_title = ''
        @chapter_id = nil
        @contents = []
        @head_contents = []
        @body_contents = []
        @foot_contents = []
        @narrator = ''
      end

      def navi_data
        (@navigation && @chapter_id && @navigation[@chapter_id]) || {}
      end

      def prev_cluster
        return nil unless @chapters
        if i = navi_data['prev_cluster']
          return @chapters[i]
        end
        nil
      end

      def next_cluster
        return nil unless @chapters
        if i = navi_data['next_cluster']
          return @chapters[i]
        end
        nil
      end

      def prev_chapter
        return nil unless @chapters
        if i = navi_data['prev']
          return @chapters[i]
        end
        nil
      end

      def next_chapter
        return nil unless @chapters
        if i = navi_data['next']
          return @chapters[i]
        end
        nil
      end

      def href
        './ch%03d.html' % @chapter_id
      end

      def display_title
        "#{@title}"
      end

      def display_sub_title
        if @chapter_id
          "Chapter #{@chapter_id} - #{@sub_title}"
        else
          "#{@sub_title}"
        end
      end

      def page_title
        if @chapter_id
          "#{@title} : #{@chapter_id} - #{@sub_title}"
        else
          "#{@title} : #{@sub_title}"
        end
      end

      def link_title
        if @chapter_id
          "#{@chapter_id} - #{@sub_title}"
        else
          "#{@sub_title}"
        end
      end

      def extract_head_data(data)
        for obj in data
          case obj
          when Tag
            val = obj.value
            case obj.key
            when 'id'        then @id = val
            when 'title'     then @title = val
            when 'sub_title' then @sub_title = val
            when 'chapter'   then @chapter_id = val.to_i
            when 'narrator'  then @narrator = val
            end
          when Parts
            @parts = obj.contents.select { |e| e.is_a?(Part) }
          when Characters
            @characters = obj.contents.select { |e| e.is_a?(Character) }
          end
          @head_contents << obj
        end
      end

      def extract_body_data(data)
        for obj in data
          @body_contents << obj
        end
      end

      def extract_foot_data(data)
        for obj in data
          @foot_contents << obj
        end
      end

      def extract_data(data)
        for obj in data
          case obj
          when Head
            @head = obj
            extract_head_data @head.contents
          when Body
            @body = obj
            extract_body_data @body.contents
          when Foot
            @foot = obj
            extract_foot_data @foot.contents
          end
          @contents << obj
        end
      end

      def setup(tokens, **options)
        data = ChapterParser.parse tokens, options
        extract_data data
      end

      def content_template_name
        case @layout_mode
        when :html
          'views/chapter.html.slim'
        when :text
          'views/chapter.txt.erb'
        end
      end
    end
  end
end
