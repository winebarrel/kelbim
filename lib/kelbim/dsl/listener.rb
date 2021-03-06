module Kelbim
  class DSL
    class EC2
      class LoadBalancer
        class Listeners
          class Listener
            include Checker
            include Kelbim::TemplateHelper

            def initialize(context, load_balancer, protocol_ports, &block)
              @error_identifier = "LoadBalancer `#{load_balancer}`: #{protocol_ports}"
              @context = context.merge(:protocol_ports => protocol_ports)

              @result = OpenStruct.new({
                :policies => []
              })

              instance_eval(&block)
            end

            attr_reader :result

            def server_certificate(value)
              call_once(:server_certificate)
              @result.server_certificate = value
            end

            def ssl_certificate_id(value)
              call_once(:ssl_certificate_id)
              @result.ssl_certificate_id = value
            end

            def policies(value)
              call_once(:policies)
              expected_type(value, Hash)

              unless value.kind_of?(Hash)
                raise "LoadBalancer `#{@load_balancer}`: #{@protocol_ports}: Invalid policies: #{value}"
              end

              value = value.map do |policy, name_or_attrs|
                expected_type(name_or_attrs, String, Hash)
                policy = PolicyTypes.symbol_to_string(policy)
                [policy, name_or_attrs]
              end

              @result.policies = value
            end

            PolicyTypes::POLICIES.keys.each do |attr_name|
              class_eval(<<-EOS, __FILE__, __LINE__ + 1)
                def #{attr_name}(name_or_attrs)
                  call_once(#{attr_name.inspect})
                  expected_type(name_or_attrs, String, Hash, Array)
                  @result.policies << [#{attr_name.inspect}, name_or_attrs]
                end
              EOS
            end
          end # Listener
        end # Listeners
      end # LoadBalancer
    end # EC2
  end # DSL
end # Kelbim
