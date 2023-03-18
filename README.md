# elm-svg-writer

Write svg and download it as a file

I would recommend using the included `Program` while you write your svg and to then download and include it into your project as a static file.

    [ Svg.Writer.rectangle { topLeft = ( 25, 25 ), width = 50, height = 50 }
    , Svg.Writer.circle { radius = 50, pos = ( 100, 100 ) }
        |> Svg.Writer.withFillColor "green"
    , Svg.Path.startAt ( 0, 100 )
        |> Svg.Path.drawCircleArcAround ( 100, 100 )
            { angle = pi / 4
            , clockwise = False
            }
        |> Svg.Path.drawLineTo ( 100, 100 )
        |> Svg.Path.endClosed
        |> Svg.Writer.path
        |> Svg.Writer.withNoFillColor
        |> Svg.Writer.withStrokeColor "blue"
        |> Svg.Writer.withStrokeWidth 25
    ]
        |> Svg.Writer.toProgram { name = "Test", width = 200, height = 200 }
