require "dnssd"
require "airplay/nodes"

module Airplay
  # Public: Browser class to find Airplay-enabled devices in the network
  #
  class Browser
    SEARCH = "_airplay._tcp."

    def initialize
      @logger = Airplay::Logger.new("airplay::browser")
    end

    # Public: Browses in the search of devices and adds them to the nodes
    #
    def browse
      timeout(3) do
        DNSSD.browse!(SEARCH) do |node|
          resolve(node)
          break unless node.flags.more_coming?
        end
      end
    end

    # Public: Access to the node list
    #
    def nodes
      @_nodes ||= Nodes.new
    end

    private

    # Private: Resolves a node given a node and a resolver
    #
    #   node - The given node
    #   resolver - The DNSSD::Server that is resolving nodes
    #
    # Returns if there are more nodes coming
    #
    def node_resolver(node, resolved)
      info = Socket.getaddrinfo(resolved.target, nil, Socket::AF_INET)
      ip = info[0][2]

      airplay_node = Node.create(
        name:     node.name,
        address: "#{ip}:#{resolved.port}",
        domain:   node.domain
      )
      airplay_node.parse_info(resolved.text_record)

      nodes << airplay_node

      resolved.flags.more_coming?
    end

    # Private: Resolves the node information given a node
    #
    #   node - The node from the DNSSD browsing
    #
    def resolve(node)
      @logger.info("Node found #{node}")
      resolver = DNSSD::Service.new
      resolver.resolve(node) do |resolved|
        break unless node_resolver(node, resolved)
      end
    end
  end
end
