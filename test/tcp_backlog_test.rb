require 'trashed/test_helper'
require 'trashed/instruments/tcp_backlog'

class TCPBacklogTest < Minitest::Test
  def tcp
     StringIO.new(<<-HEREDOC
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
   0: 00000000:0444 00000000:0000 0A 00000000:00000000 00:00000000 00000000  3000        0 1134219 1 0000000000000000 100 0 0 10 0
   1: 0100007F:A5B6 00000000:0000 0A 00000000:00000000 00:00000000 00000000  3000        0 1132233 1 0000000000000000 100 0 0 10 0
   2: 928F000A:8586 0529010A:2352 01 00000000:00000000 00:00000000 00000000  3000        0 1132386 1 0000000000000000 21 4 6 10 -1
   3: 928F000A:B1B0 B14E010A:2352 01 00000000:00000000 00:00000000 00000000  3000        0 1134325 1 0000000000000000 20 4 6 10 -1
   4: 928F000A:D02A 0431010A:18EB 01 00000000:00000000 00:00000000 00000000  3000        0 1142465 1 0000000000000000 20 4 28 10 -1
   5: 928F000A:9070 7F0A010A:2352 01 00000000:00000000 00:00000000 00000000  3000        0 1132516 1 0000000000000000 20 4 6 10 -1
   6: 928F000A:B1A0 B14E010A:2352 01 00000000:00000000 00:00000000 00000000  3000        0 1134323 1 0000000000000000 20 4 6 10 -1
   7: 928F000A:B194 B14E010A:2352 01 00000000:00000000 00:00000000 00000000  3000        0 1132452 1 0000000000000000 20 4 6 10 -1
   8: 928F000A:B19E B14E010A:2352 01 00000000:00000000 00:00000000 00000000  3000        0 1132455 1 0000000000000000 20 4 6 10 -1
  HEREDOC
                 )
  end

  def tcp6
     StringIO.new(<<-HEREDOC
  sl  local_address                         remote_address                        st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
   0: 00000000000000000000000000000000:0444 00000000000000000000000000000000:0000 0A 00000000:00000000 00:00000000 00000000  3000        0 1134221 1 0000000000000000 100 0 0 10 0
   1: 00000000000000000000000000000000:BEF0 00000000000000000000000000000000:0000 0A 00000000:00000000 00:00000000 00000000  3000        0 1134365 1 0000000000000000 100 0 0 10 0
   2: 0000000000000000FFFF0000028011AC:BEF0 0000000000000000FFFF0000018011AC:542A 01 00000000:00000000 02:000008C9 00000000  3000        0 1142505 2 0000000000000000 20 4 33 10 -1
   HEREDOC
                 )
  end

  def test_proc_tcp
    # filter parsed file by each of these statuses, expecting N entries
    # returned as a result
    tests = {
      Trashed::Instruments::TCP_LISTEN      => 2,
      Trashed::Instruments::TCP_ESTABLISHED => 7,

      # ensure we don't find what's not there
      Trashed::Instruments::TCP_LAST_ACK    => 0,
    }

    tests.each_pair do |st, expected|
      count = 0
      Trashed::Instruments::ProcTCP.new(tcp).by(:st => st) do |entry|
        count += 1
      end
      assert_equal expected, count
    end
  end

  def test_proc_tcp6
    # filter parsed file by each of these statuses, expecting N entries
    # returned as a result
    tests = {
      Trashed::Instruments::TCP_LISTEN      => 2,
      Trashed::Instruments::TCP_ESTABLISHED => 1,

      # ensure we don't find what's not there
      Trashed::Instruments::TCP_LAST_ACK    => 0,
    }

    tests.each_pair do |st, expected|
      count = 0
      Trashed::Instruments::ProcTCP.new(tcp6).by(:st => st) do |entry|
        count += 1
      end
      assert_equal expected, count
    end

  end
end
