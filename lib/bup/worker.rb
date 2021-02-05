module Bup
  class Worker
    def initialize(src_dir, dest_dir)
      @src_dir = src_dir
      @dest_dir = dest_dir
    end

    def run
      buffer = build_buffer

      (1..4).each { |_| build_worker(buffer) }

      glob = File.join(@src_dir, '**/*')

      Dir[glob].each do |path|
        buffer.send path
      end
    end

    private

    def build_buffer
      Ractor.new do
        loop do
          Ractor.yield Ractor.receive
        end
      end
    end

    def build_worker(buffer)
      Ractor.new(@dest_dir, buffer) do |_dest_dir, buffer|
        loop do
          path = buffer.take
          puts path
        end
      end
    end
  end
end
