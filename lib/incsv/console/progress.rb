require "io/console"

module InCSV
  class Progress
    def initialize(output: $stdout, message: "Working...")
      @output = output
      @message = message
    end

    def indeterminate
      loop do
        line
        sleep 1
      end
    end

    def clear
      output.print "\r"
      output.print " " * width
    end

    private

    def width
      _, columns = $stdout.winsize
      columns
    end

    def line
      @offset ||= 0
      @offset += 1

      inner_width = width - 3 - message.length
      units = (width / 4.to_f).ceil

      output.print "\r#{message} |"

      case @offset % 4
      when 0
        output.print ("=---" * units)[0...inner_width]
      when 1
        output.print ("-=--" * units)[0...inner_width]
      when 2
        output.print ("--=-" * units)[0...inner_width]
      when 3
        output.print ("---=" * units)[0...inner_width]
      end

      output.print "|"
    end

    attr_reader :output, :message
  end
end
