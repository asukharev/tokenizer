module Scanner

using MLStyle

import Base.+

export lexemes

@data Kind begin
    # 
    # begin_control
    EOT
    WHITESPACE
    FLOAT_PUNCTUATION
    PUNCTUATION
    # end_control
    # 
    # begin_group
    GROUP_START
    GROUP_END
    # end_group
    #
    # begin_onechar
    LETTER(Char)
    CAPITAL_LETTER(Char)
    DIGIT(Number)
    # end_onechar
    # 
    # begin_deriv
    EQ
    OP(Char)
    INT_NUMBER(Number)
    FLOAT_NUMBER(Number)
    # PROPERTY
    # LETTER_NUMERIC_PROPERTY
    WORD(String)
    # SENTENCE
    # end_deriv
end

(+)(::Nothing, b::Kind) = b == WHITESPACE ? nothing : b

(+)(::Nothing, ::Nothing) = nothing

(+)(a::Kind, b::Kind) = @match (a, b) begin
    # 
    (CAPITAL_LETTER(cl), LETTER(l)) => WORD(string(cl, l));
    (CAPITAL_LETTER(cl1), CAPITAL_LETTER(cl2)) => WORD(string(cl1, cl2));
    (WORD(w), CAPITAL_LETTER(cl)) => WORD(string(w, cl));
    (LETTER(l1), LETTER(l2)) => WORD(string(l1, l2));
    (WORD(w), LETTER(l)) => WORD(string(w, l));
    # 
    (DIGIT(d1), DIGIT(d2)) => INT_NUMBER(d1 * 10 + d2);
    (INT_NUMBER(n), DIGIT(d)) => INT_NUMBER(n * 10 + d);
    (DIGIT(d), FLOAT_PUNCTUATION) => FLOAT_NUMBER(d * 1.0);
    (FLOAT_NUMBER(f), DIGIT(d)) => begin
        s = isinteger(f) ? string(Int64(floor(f)), '.') : string(f)
        s = string(s, d)
        return FLOAT_NUMBER(parse(Float64, s))
    end;
    # 
    (GROUP_START, v) => [GROUP_START; v];
    (v, GROUP_START) => [v; GROUP_START];
    (v, GROUP_END) => [v; GROUP_END; nothing];
    (GROUP_END, v) => [GROUP_END; v];
    #
    (v, OP(op)) => [v; OP(op); nothing]
    #
    (_, WHITESPACE) => EOT;
    _ => nothing;
end


(+)(::Nothing, ch::Char) = Array{Union{Nothing,Kind}}([kindof(ch)])

(+)(a::Array{Union{Nothing,Kind}}, ch::Char) = begin
    l = last(a)
    kind = l + kindof(ch)
    println("$l + $(kindof(ch)) = $(kind)")
    if kind == EOT
        return [a; nothing]
    elseif isnothing(kind)
        return a
    else
        return [a[1:end - 1]; kind]
    end
end



kindof(ch::Char) = @match ch begin
    ch::Char && if ch ∈ ['(', '[', '{'] end => GROUP_START;
    ch::Char && if ch ∈ [')', ']', '}'] end => GROUP_END;
    ch::Char && if ch ∈ ['.', ','] end => FLOAT_PUNCTUATION;
    ch::Char && if ch ∈ ['-', '+', '/', '*'] end => OP(ch);
    ch::Char && if ch ∈ ['>', '<', '='] end => EQ;
    ch::Char && if isdigit(ch) end => DIGIT(parse(Int8, ch));
    ch::Char && if isspace(ch) end => WHITESPACE;
    ch::Char && if ispunct(ch) end => PUNCTUATION;
    ch::Char && if isuppercase(ch) end => CAPITAL_LETTER(ch);
    ch::Char => LETTER(ch);
    _ => nothing;
end

lexemes(S::String) = foldl(+, S; init = nothing)

end # module
