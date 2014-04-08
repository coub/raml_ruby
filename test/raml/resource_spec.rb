require_relative 'spec_helper'

describe Raml::Resource do
  let (:data) {
    YAML.load(%q(
      post:
        description: Создание загрузки
      /{id}:
        uriParameters:
          id:
            type: integer
            required: true
            example: 277102
        /processing_status:
          get:
            description: Получить статус загрузки
            responses:
              200:
                body:
                  application/json:
                    example: |
                      {
                        "percent": 0,
                        "type": "download",
                        "status":"initial"
                      }
    ))
  }

  it "should instanciate Resource" do
    resource = Raml::Resource.new(data)
  end
end
