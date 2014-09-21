# @private
class Module
  private
  def attr_reader_default(attribute, default)
    alias_method("#{attribute}_orig".to_sym, attribute) unless method_defined? "#{attribute}_orig"

    define_method attribute do
      val = send("#{attribute}_orig".to_sym)
      val.nil? ? default : val
    end
  end
end