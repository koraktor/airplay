require "airplay"
require "ruby-progressbar"

module Airplay
  module CLI
    class << self
      def list
        Airplay.nodes.each do |node|
          puts <<-EOS.gsub(/^\s{12}/,'')
            * #{node.name} (#{node.info.model} running #{node.info.os_version})
              ip: #{node.ip}
              resolution: #{node.info.resolution}

          EOS
        end
      end

      def play(video, options)
        node = options[:node]
        player = node.play(video)
        puts "Playing #{video}"
        bar = ProgressBar.create(
          title: node.name,
          format: "%a [%B] %p%% %t"
        )

        player.progress -> playback {
          bar.progress = playback.percent
        }

        player.wait
      end

      def view(file_or_dir, options)
        node = options[:node]
        wait = options[:wait]

        if File.directory?(file_or_dir)
          files = Dir.glob("#{file_or_dir}/*")

          if options[:interactive]
            view_interactive(files)
          else
            view_slideshow(files)
          end
        else
          view_image(node, file_or_dir)
          sleep
        end
      end

      private

      def view_interactive(files)
        numbers = Array(0...files.count)
        transition = "None"

        i = 0
        loop do
          puts i
          view_image(node, files[i], transition)

          case read_char
            # Right Arrow
          when "\e[C"
            i = i + 1 > numbers.count - 1 ? 0 : i + 1
            transition = "SlideLeft"
          when "\e[D"
            i = i - 1 < 0 ? numbers.count - 1 : i - 1
            transition = "SlideRight"
          else
            break
          end
        end
      end

      def view_slideshow(files)
        files.each do |file|
          view_image(node, file)
          sleep wait
        end
      end

      def read_char
        STDIN.echo = false
        STDIN.raw!

        input = STDIN.getc.chr
        if input == "\e" then
          input << STDIN.read_nonblock(3) rescue nil
          input << STDIN.read_nonblock(2) rescue nil
        end
      ensure
        STDIN.echo = true
        STDIN.cooked!

        return input
      end

      def view_image(node, image, transition = "SlideLeft")
        node.view(image, transition: transition)
      end
    end
  end
end
