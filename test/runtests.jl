using Test
using Tokenizer: lexemes

@testset "tokens test" begin
    s = "Болты 8х40 анкерные 5.34 Метизная Торговая Компания Сртв (8452) 72-88-96 доб. ГОСТ"
    _lexemes = lexemes(s)
    @test _lexemes == ""
end