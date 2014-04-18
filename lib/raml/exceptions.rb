module Raml
  # Abstract parameter
  class InvalidParameterType < StandardError; end
  class NamedParameterNotApplicable < StandardError; end

  # Root
  class RootTitleMissing < StandardError; end
  class RootBaseUriMissing < StandardError; end
end
