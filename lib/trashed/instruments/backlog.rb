module Trashed
  module Instruments
    TCP_ESTABLISHED = 1
    TCP_SYN_SENT = 2
    TCP_SYN_RECV = 3
    TCP_FIN_WAIT1 = 4
    TCP_FIN_WAIT2 = 5
    TCP_TIME_WAIT = 6
    TCP_CLOSE = 7
    TCP_CLOSE_WAIT = 8
    TCP_LAST_ACK = 9
    TCP_LISTEN = 10
    TCP_CLOSING = 11

    class ListenBacklog
      def initialize(pid = nil)
        @pid = nil
      end

      def start(state, counters, gauges)
      end

      def measure(state, counters, gauges)
        count = 0
        if @pid then
          basefile = "/proc/#{@pid}/"
        else
          basefile = "/proc/net/"
        end

        [:tcp, :tcp6].each do |name|
          ProcTCP.new(File.open(basefile + name)).by(:st => TCP_SYN_RECV) do |entry|
            count += 1
          end
        end

        gauges["TCP.backlog"] = count
      end
    end

    class ProcTCP
      def initialize(file, pid=nil)
        @file = file
        @pid = pid
      end

      def by(filters = {})
        @file.readline # header, ignore
        @file.readlines.each do |line|
          entry = TCPEntry.new(line)
          if entry.matches?(filters) then
            yield entry
          end
        end
      end
    end

    class TCPEntry
      def initialize(line)
        pieces = line.split(/(:|\s+)/).map(&:strip).select do |x|
          x != ":" and x.length > 0
        end

        @attrs = {
          :local_addr => toip(pieces[1]),
          :local_port => pieces[2].hex,
          :remote_addr => toip(pieces[3]),
          :remote_port => pieces[4].hex,
          :st => pieces[5].hex,
          :tx_queue => pieces[6].to_i,
          :rx_queue => pieces[7].to_i,
          :tr => pieces[8].hex,
          :tm_when => pieces[9],
          :retrnsmt => pieces[10],
          :uid => pieces[11].to_i,
          :timeout => pieces[12].to_i,
          :inode => pieces[13].to_i,
        }
      end

      def attr(name)
        @attrs[name]
      end

      def matches?(params = {})
        ret = true
        params.each do |key, value|
          ret = false if @attrs[key] != value
        end
        ret
      end

      private

      def toip(piece)
        if piece.length == 8
          i = piece.hex
          "#{i & 0xff}.#{(i >> 8) & 0xff}.#{(i >> 16) & 0xff}.#{(i >> 24) & 0xff}"
        else
          parts = piece.scan(/..../).collect do |part|
            part[2..3] + part[0..1]
          end
          parts.join(':')
        end
      end
    end
  end
end
