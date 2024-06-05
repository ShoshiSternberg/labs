// The months
definition September() returns uint8 = 9;
definition October() returns uint8 = 10;
definition November() returns uint8 = 11;
definition December() returns uint8 = 12;

rule sistersBirthMonths(
    uint8 Sara,
    uint Ophelia,
    uint Nora,
    uint Dawn
){

    require Sara>=September()&&Sara<=December();
    require Ophelia>=September()&&Sara<=December();
    require Nora>=September()&&Sara<=December();
    require Dawn>=September()&&Sara<=December();
    require (
        Sara!=September()&&
        Ophelia!=October()&&
        Nora!=November()&&
        Dawn!=December()
    );
    require Ophelia!=September();
    require Nora!=September();
    require Nora!=October();
    require (
        Sara!=Ophelia&&
        Sara!=Nora&&
        Sara!=Dawn&&
        Ophelia!=Nora&&
        Ophelia!=Dawn&&
        Nora!=Dawn
    );
    satisfy true;
}