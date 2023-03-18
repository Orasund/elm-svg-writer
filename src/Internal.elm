module Internal exposing (..)


rotateBy angle ( x, y ) =
    ( x * cos angle - y * sin angle
    , x * sin angle - y * cos angle
    )


plus ( x1, y1 ) ( x2, y2 ) =
    ( x1 + x2, y1 + y2 )


length ( x, y ) =
    (x * x)
        |> (+) (y * y)
        |> sqrt


scaleBy float ( x, y ) =
    ( x * float, y * float )


normalize ( x, y ) =
    let
        l =
            length ( x, y )
    in
    ( x / l, y / l )
