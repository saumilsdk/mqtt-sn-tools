$:.unshift(File.dirname(__FILE__))

require 'test_helper'

class MqttSnSubTest < Minitest::Test

  def test_usage
    @cmd_result = run_cmd('mqtt-sn-sub', '-?')
    assert_match /^Usage: mqtt-sn-sub/, @cmd_result[0]
  end

  def test_custom_client_id
    fake_server do |fs|
      @packet = fs.wait_for_packet(MQTT::SN::Packet::Connect) do
        @cmd_result = run_cmd(
          'mqtt-sn-sub',
          ['-1',
          '-i', 'test_custom_client_id',
          '-t', 'test',
          '-p', fs.port]
        )
      end
    end

    assert_equal ["Hello World\n"], @cmd_result
    assert_equal 'test_custom_client_id', @packet.client_id
    assert_equal 10, @packet.keep_alive
  end

  def test_subscribe_one
    fake_server do |fs|
      @packet = fs.wait_for_packet(MQTT::SN::Packet::Subscribe) do
        @cmd_result = run_cmd(
          'mqtt-sn-sub',
          ['-1',
          '-t', 'test',
          '-p', fs.port]
        )
      end
    end

    assert_equal ["Hello World\n"], @cmd_result
    assert_equal 'test', @packet.topic_name
    assert_equal :normal, @packet.topic_id_type
    assert_equal 0, @packet.qos
  end

  def test_subscribe_one_verbose
    fake_server do |fs|
      @packet = fs.wait_for_packet(MQTT::SN::Packet::Subscribe) do
        @cmd_result = run_cmd(
          'mqtt-sn-sub',
          ['-1', '-v',
          '-t', 'test',
          '-p', fs.port]
        )
      end
    end
    
    assert_equal ["test: Hello World\n"], @cmd_result
    assert_equal 'test', @packet.topic_name
    assert_equal :normal, @packet.topic_id_type
    assert_equal 0, @packet.qos
  end

  def test_subscribe_one_verbose_time
    fake_server do |fs|
      @packet = fs.wait_for_packet(MQTT::SN::Packet::Subscribe) do
        @cmd_result = run_cmd(
          'mqtt-sn-sub',
          ['-1', '-V',
          '-t', 'test',
          '-p', fs.port]
        )
      end
    end

    assert_equal 1, @cmd_result.count
    assert_match /\d{4}\-\d{2}\-\d{2} \d{2}\:\d{2}\:\d{2} test: Hello World/, @cmd_result[0]
    assert_equal 'test', @packet.topic_name
    assert_equal :normal, @packet.topic_id_type
    assert_equal 0, @packet.qos
  end

  def test_subscribe_one_short
    fake_server do |fs|
      @packet = fs.wait_for_packet(MQTT::SN::Packet::Subscribe) do
        @cmd_result = run_cmd(
          'mqtt-sn-sub',
          ['-1', '-v',
          '-t', 'tt',
          '-p', fs.port]
        )
      end
    end
    
    assert_equal ["tt: Hello World\n"], @cmd_result
    assert_equal 'tt', @packet.topic_name
    assert_equal :short, @packet.topic_id_type
    assert_equal 0, @packet.qos
  end

  def test_subscribe_one_predefined
    fake_server do |fs|
      @packet = fs.wait_for_packet(MQTT::SN::Packet::Subscribe) do
        @cmd_result = run_cmd(
          'mqtt-sn-sub',
          ['-1', '-v',
          '-T', 17,
          '-p', fs.port]
        )
      end
    end

    assert_equal ["0011: Hello World\n"], @cmd_result
    assert_nil @packet.topic_name
    assert_equal 17, @packet.topic_id
    assert_equal :predefined, @packet.topic_id_type
    assert_equal 0, @packet.qos
  end

end