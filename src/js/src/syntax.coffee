get_octave = (symbol) ->
    for i in [0...octaves.length]
        if (octaves.charAt i) == symbol
            return i

    throw new InvalidSymbolError

get_splitter_length = (symbol) ->
    return splitter_length[symbol]

tokenize = (expr) ->
    if expr.length <= 1
        return [expr]

    stack = [expr.charAt(0)]

    for current in (expr.charAt(i) for i in [1...expr.length])
        previous = stack.pop()
        if (
            current == operators.special_splitter and
            previous == operators.special_splitter
        ) or (
            current == 'n' and previous == '\\'
        ) or (
            (current == keys[0] and previous == keys[1]) or
            (current == keys[1] and previous == keys[0])
        ) or (
            current in chord_set and previous.charAt(0) in chord_set
        )
            stack.push (previous + current)
        else
            stack.push previous
            stack.push current

    return stack

parse = (expr) ->
    stack = tokenize expr

    tree = []

    for token in stack
        if token == '\n'
            tree.push (new Newline())

        else if token in operators.splitters
            tree.push (new Splitter (get_splitter_length token))
            continue

        else if key_tokens[token] != undefined
            tree.push (new Key(key_tokens[token]))
            continue

        chord_notes = []

        for symbol in token
            try
                chord_notes.push (new Note (get_octave symbol))
            catch error

        if chord_notes.length > 0
            tree.push (new Chord chord_notes)

    return tree
