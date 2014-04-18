( keys, values, rereduce ) ->

  result =
    subtests       : 0
    didntMeet      : 0
    metBenchmark   : 0
    benchmarked    : 0
    itemsPerMinute : []

  for value in values
    for k, v of value

      if k is "subtests"
        result.subtests += v

      else if k is "itemsPerMinute"

        unless rereduce
          for ipm in v
            continue if ipm >= 120
            result.itemsPerMinute.push ipm
            result.benchmarked++

      else if k is "minTime"
        result.minTime = v unless result.minTime?
        result.minTime = if result.minTime < v then result.minTime else v

      else if k is "maxTime"
        result.maxTime = v unless result.maxTime?
        result.maxTime = if result.maxTime > v then result.maxTime else v

      else
        # this only works if none of the other values have the same key
        result[k] = v

  #
  # benchmark
  #

  if result.subject and result.class and result.itemsPerMinute

    english = result.subject is "english_word"
    swahili = result.subject is "word"
    class1  = result.class   is "1"
    class2  = result.class   is "2"

    for ipm in result.itemsPerMinute

      result.metBenchmark++ if swahili and class1 and ipm >= 17
      result.metBenchmark++ if swahili and class2 and ipm >= 45
      result.metBenchmark++ if english and class1 and ipm >= 30
      result.metBenchmark++ if english and class2 and ipm >= 65

  return result