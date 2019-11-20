# frozen_string_literal: true

module LunaPark
  module CLI
    module Commands
      module Generate
        class FormSingle < Hanami::CLI::Command
          desc 'Solution for a form which process single request'

          argument :path, required: true, type: :string, desc: 'Destination class path'
          option   :create_dir, type: :boolean, default: true, desc: 'Auto create dir if no exists'
          option   :inputs, type: :array, default: %w[foo bar], desc: 'Form inputs'

          example [
            'app/bill/forms/create # Generate bill create form'
          ]

          def call(path:, **opts)
            Interactors::SinglePattern.call pattern: :form, type: :single, at: path, opts: opts
          end

          # class Options < Struct(:inputs)
          #   def double_inputs
          #     'foo: foo, bar: bar'
          #   end
          # end
        end
      end
    end
  end
end
