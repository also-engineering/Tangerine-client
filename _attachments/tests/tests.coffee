$(document).ready ->
  module "Basic Unit Test"
  test "Sample test", ->
    expect(1)
    equals(4/2,2)
  module "EGRA"

  QUnit.testStart = (name) ->
    console.log name
    localStorage.clear()

  test "JQueryMobilePage", ->
    expect(1)
    test_object = new JQueryMobilePage()
    test_object.pageId = "pageId"
    test_object.footer = "footer_text"
    test_object.header = "header"
    test_object.content = "content"
    expected_result = "<div data-role='page' id='pageId'>  <div data-role='header'>    header  </div><!-- /header -->  <div data-role='content'>	        content  </div><!-- /content -->  <div data-role='footer'>    footer_text  </div><!-- /header --></div><!-- /page -->"

    equals(test_object.render(), expected_result)


  test "JQueryCheckbox", ->
    expect(1)
    test_object = new JQueryCheckbox()
    test_object.unique_name = "unique_name"
    test_object.content = "content"
    expected_result = "
<input type='checkbox' name='unique_name' id='unique_name' class='custom' /><label for='unique_name'>content</label>"
    equals(test_object.render(), expected_result)

  test "JQueryCheckboxGroup", ->
    expect(1)
    test_object = new JQueryCheckboxGroup()
    test_object.checkboxes = []
    test_object1 = new JQueryCheckbox()
    test_object1.unique_name = "unique_name"
    test_object1.content = "content"
    test_object.checkboxes.push(test_object1)
    expected_result = "
<div data-role='content'>	  <form>    <fieldset data-role='controlgroup' data-type='horizontal' data-role='fieldcontain'><input type='checkbox' name='unique_name' id='unique_name' class='custom' /><label for='unique_name'>content</label></fieldset>  </form></div>    "
    equals(test_object.render(), expected_result)

  test "JQueryLogin", ->
    expect(1)
    test_object = new JQueryLogin()
    expected_result = "
<form>
  <div data-role='fieldcontain'>
    <label for='username'>Username:</label>
    <input type='text' name='username' id='username' value='Enumia' />
    <label for='password'>Password (not needed for demo):</label>
    <input type='password' name='password' id='password' value='' />
  </div>
</form>
"
    equals(test_object.render(), expected_result)

  test "Timer", ->
    expect(1)
    test_object = new Timer()
    expected_result = "<div class='timer'>  <span class='timer_seconds'>60</span>  <a href='#' data-role='button'>start</a>  <a href='#' data-role='button'>stop</a>  <a href='#' data-role='button'>reset</a></div>"
    equals(test_object.render(), expected_result)

  test "LocalStorage Create/Delete", ->
    assessment = new Assessment()
    assessment.name = "Test EGRA Prototype"
    login = new JQueryMobilePage()
    login.pageId = "Login"
    assessment.setPages([login])
    equals(localStorage["Assessment.Test EGRA Prototype"],null)
    equals(localStorage["Assessment.Test EGRA Prototype.Login"],null)
    assessment.saveToLocalStorage()
    notEqual(localStorage["Assessment.Test EGRA Prototype"],null)
    notEqual(localStorage["Assessment.Test EGRA Prototype.Login"],null)
    assessment.deleteFromLocalStorage()
    equals(localStorage["Assessment.Test EGRA Prototype"],null)
    equals(localStorage["Assessment.Test EGRA Prototype.Login"],null)


  test "LocalStorage Serialization", ->
    expect(4)
    assessment = new Assessment()
    assessment.name = "Test EGRA Prototype"
    login = new JQueryMobilePage()
    instructions = new InstructionsPage()
    letters = new LettersPage()

    login.pageId = "Login"
    login.header = "<h1>EGRA</h1>"
    login.content = (new JQueryLogin()).render()

    instructions.pageId = "Instructions"
    instructions.header = "<h1>EGRA</h1>"
    instructions.url = "https://spreadsheets.google.com/pub?key=0Ago31JQPZxZrdGJSZTY2MHU4VlJ3RnNtdnNDVjRjLVE&hl=en&output=html"
    instructions.updateFromGoogle()

    letters.pageId = "Letters"
    letters.header = "<h1>EGRA</h1>"
    letters.url = "https://spreadsheets.google.com/pub?key=0Ago31JQPZxZrdC1MeGVqd3FZbXM2RnNFREtoVVZFbmc&hl=en&output=html"
    letters.updateFromGoogle()

    assessment.setPages([login, instructions,letters])

    stop()
    assessment.onReady ->
      index = letters.index()
      letters.saveToLocalStorage()
      result = JQueryMobilePage.loadFromLocalStorage(index)
      equals(result.render(), letters.render())
      equals(result.content, letters.content)

      anotherAssessment = new Assessment()
      anotherAssessment.name = assessment.name
      assessment.saveToLocalStorage()
      # Since name is same, it will deserialize from assessment
      anotherAssessment.loadFromLocalStorage()
      anotherAssessment.onReady ->
        equal(assessment.pages.length, anotherAssessment.pages.length)
        equal(assessment.render(), anotherAssessment.render())
        start()

  
  test "CouchDB Create/Delete", ->
    assessment = new Assessment()
    assessment.name = "Test EGRA Prototype"
    assessment.deleteFromCouchDB
    login = new JQueryMobilePage()
    login.pageId = "Login"
    assessment.setPages([login])
    stop()
    assessment.saveToCouchDB( ->
      console.log assessment.revision
      notEqual(assessment.revision,null)
      start()

  test "CouchDB Serialization", ->
    # Clear existing documents

    expect(3)
    assessment = new Assessment()
    assessment.name = "TEST EGRA Prototype"
    login = new JQueryMobilePage()
    instructions = new InstructionsPage()
    letters = new LettersPage()

    login.pageId = "Login"
    login.header = "<h1>EGRA</h1>"
    login.content = (new JQueryLogin()).render()

    instructions.pageId = "Instructions"
    instructions.header = "<h1>EGRA</h1>"
    instructions.url = "https://spreadsheets.google.com/pub?key=0Ago31JQPZxZrdGJSZTY2MHU4VlJ3RnNtdnNDVjRjLVE&hl=en&output=html"
    instructions.updateFromGoogle()

    letters.pageId = "Letters"
    letters.header = "<h1>EGRA</h1>"
    letters.url = "https://spreadsheets.google.com/pub?key=0Ago31JQPZxZrdC1MeGVqd3FZbXM2RnNFREtoVVZFbmc&hl=en&output=html"
    letters.updateFromGoogle()

    assessment.setPages([login, instructions,letters])

    stop()
    assessment.onReady ->
      letters.saveToCouchDB()
      # Wait 1 second for the save to complete
      loadFunction = ->
        JQueryMobilePage.loadFromCouchDB letters.index(), (result) ->
          equals(result.render(), letters.render())
          equals(result.content, letters.content)
      setTimeout(loadFunction,1000)

      anotherAssessment = new Assessment()
      anotherAssessment.name = assessment.name
      assessment.saveToCouchDB()
      loadFunction = ->
        # Since name is same, it will deserialize from assessment
        anotherAssessment.loadFromCouchDB()
        anotherAssessment.render (anotherAssessmentResult) ->
          assessment.render (assessmentResult) ->
            $.a=assessment
            $.b=anotherAssessment
            equals(anotherAssessmentResult, assessmentResult)
            start()
      setTimeout(loadFunction,1000)
