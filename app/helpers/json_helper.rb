module JsonHelper
    def transform_data(serialized_data)
      serialized_data.map do |data|
        data[:attributes]
      end
    end
  end