# @private
class Hash
  def map!(&block)
    replace Hash[ map(&block) ]
  end
end