class DataRequest
  @title = ""
  @titleOperator = ""
  @categoryArray = ""
  @categoryOperator = ""
  @ingridientArray = ""
  @ingridientOperator = ""
  @includePictures = ""
  @id = 0
  @output = ""
  def setId(id)
    @id = id
  end
  def getId
    return @id
  end
  def setOutput(output)
    @output = output
  end
  def getOutput
    return @output
  end
  
  def setTitle(title)
    @title = title
  end
  def setTitleOperator(titleOperator)
      @titleOperator = titleOperator
    end
  def setCategoryArray(categoryArray)
      @categoryArray = categoryArray
    end
  def setCategoryOperator(categoryOperator)
      @categoryOperator = categoryOperator
    end
  def setIngridientArray(ingridientArray)
      @ingridientArray = ingridientArray
    end
  def setIngridientOperator(ingridientOperator)
      @ingridientOperator = ingridientOperator
    end
  def setIncludePictures(includePictures)
    @includePictures = includePictures
  end
  
  def getTitle
      return @title
    end
    def getTitleOperator
      return @titleOperator
      end
    def getCategoryArray
      return @categoryArray
      end
    def getCategoryOperator
      return @categoryOperator 
      end
    def getIngridientArray
      return @ingridientArray 
      end
    def getIngridientOperator
      return @ingridientOperator 
      end
    def getIncludePictures
      return @includePictures 
    end
end