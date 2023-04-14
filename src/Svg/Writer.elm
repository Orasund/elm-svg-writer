module Svg.Writer exposing
    ( SvgNode(..), circle, rectangle, path
    , define, defineMask, use
    , group, custom
    , withFillColor, withNoFillColor
    , withStrokeColor, withStrokeWidth, withNoStrokeColor
    , withMask
    , withCustomAttribute
    , toString, toHtml, toDataURI
    , Program, toProgram
    , withAttribute
    )

{-|


# Svg

@docs SvgNode, circle, rectangle, path

@docs define, defineMask, use

@docs group, custom


# Attributes

@docs withFillColor, withNoFillColor
@docs withStrokeColor, withStrokeWidth, withNoStrokeColor
@docs withMask
@docs withCustomAttribute


# Conversion

@docs toString, toHtml, toDataURI


# Interactive Viewer

@docs Program, toProgram


# Deprecated

@docs withAttribute

-}

import Browser
import File.Download
import Html exposing (Attribute, Html)
import Html.Attributes
import Html.Events
import Svg.Path exposing (Path)


{-| A Svg Node.

It can be turned into a string using `toString` or into html using `toHtml`.

-}
type SvgNode
    = SvgNode
        { name : String
        , attributes : List ( String, String )
        , content : List SvgNode
        }


{-| Custom node
-}
custom : String -> List SvgNode -> SvgNode
custom name list =
    SvgNode { name = name, attributes = [], content = list }


{-| group nodes to apply styling to all nodes at once.
-}
group : List SvgNode -> SvgNode
group list =
    SvgNode { name = "g", attributes = [], content = list }


{-| define a mask.

You can use the mask with `withMask`.

-}
defineMask : String -> List SvgNode -> SvgNode
defineMask id list =
    SvgNode
        { name = "mask"
        , attributes = [ ( "id", id ) ]
        , content = list
        }


{-| define a template.

You can use a template with `use`.

-}
define : List ( String, SvgNode ) -> SvgNode
define list =
    SvgNode
        { name = "defs"
        , attributes = []
        , content =
            list
                |> List.map
                    (\( id, svgNode ) ->
                        svgNode |> withAttribute ( "id", id )
                    )
        }


{-| Use a defined template
-}
use : String -> SvgNode
use id =
    SvgNode
        { name = "use"
        , attributes = [ ( "href", "#" ++ id ) ]
        , content = []
        }


{-| Use a defined mask
-}
withMask : String -> SvgNode -> SvgNode
withMask id =
    withAttribute ( "mask", "url(#" ++ id ++ ")" )


{-| use no color for the filling
-}
withNoFillColor : SvgNode -> SvgNode
withNoFillColor =
    withAttribute ( "fill", "none" )


{-| fill the shape with a color
-}
withFillColor : String -> SvgNode -> SvgNode
withFillColor string =
    withAttribute ( "fill", string )


{-| don't draw the border of the shape
-}
withNoStrokeColor : SvgNode -> SvgNode
withNoStrokeColor =
    withAttribute ( "stroke", "none" )


{-| use a color for the border of the shape
-}
withStrokeColor : String -> SvgNode -> SvgNode
withStrokeColor string =
    withAttribute ( "stroke", string )


{-| define the with of the border of the shape
-}
withStrokeWidth : Float -> SvgNode -> SvgNode
withStrokeWidth strokeWidth =
    withAttribute ( "stroke-width", String.fromFloat strokeWidth )


{-| @Deprecated

Use `withCustomAttribute` instead.

-}
withAttribute : ( String, String ) -> SvgNode -> SvgNode
withAttribute ( name, value ) =
    withCustomAttribute name value


{-| add a attribute
-}
withCustomAttribute : String -> String -> SvgNode -> SvgNode
withCustomAttribute name value (SvgNode svgNode) =
    { svgNode | attributes = ( name, value ) :: svgNode.attributes }
        |> SvgNode


{-| turn a path into a svg node.
-}
path : Path -> SvgNode
path p =
    SvgNode
        { name = "path"
        , attributes = [ ( "d", Svg.Path.toString p ) ]
        , content = []
        }


{-| create a rectangle svg node
-}
rectangle : { topLeft : ( Float, Float ), width : Float, height : Float } -> SvgNode
rectangle args =
    let
        ( x, y ) =
            args.topLeft
    in
    SvgNode
        { name = "rect"
        , attributes =
            [ ( "x", String.fromFloat x )
            , ( "y", String.fromFloat y )
            , ( "width", String.fromFloat args.width )
            , ( "height", String.fromFloat args.height )
            ]
        , content = []
        }


{-| define a cirlce svg node
-}
circle : { radius : Float, pos : ( Float, Float ) } -> SvgNode
circle args =
    let
        ( x, y ) =
            args.pos
    in
    SvgNode
        { name = "circle"
        , attributes =
            [ ( "cx", String.fromFloat x )
            , ( "cy", String.fromFloat y )
            , ( "r", String.fromFloat args.radius )
            ]
        , content = []
        }


{-| Convert the list of svg nodes into a svg-string.
-}
toString : { width : Int, height : Int } -> List SvgNode -> String
toString args list =
    let
        rec depth (SvgNode node) =
            (List.repeat (depth * 2) " "
                |> String.concat
            )
                ++ "<"
                ++ node.name
                ++ " "
                ++ (node.attributes
                        |> List.map (\( name, value ) -> name ++ "=\"" ++ value ++ "\"")
                        |> String.join " "
                   )
                ++ (if node.content == [] then
                        "/>\n"

                    else
                        ">\n"
                            ++ (node.content
                                    |> List.map (rec (depth + 1))
                                    |> String.concat
                               )
                            ++ (List.repeat (depth * 2) " "
                                    |> String.concat
                               )
                            ++ "</"
                            ++ node.name
                            ++ ">\n"
                   )
    in
    "<svg version=\"1.1\" width=\""
        ++ String.fromInt args.width
        ++ "\" height=\""
        ++ String.fromInt args.height
        ++ "\" xmlns=\"http://www.w3.org/2000/svg\">\n"
        ++ (list |> List.map (rec 1) |> String.concat)
        ++ "</svg>"


{-| turn the list of svg nodes into a data URI.

    backgroundImage : Html.Attribute msg
    backgroundImage =
        Html.Attributes.style "background-image"
            ( "url(\\""
                ++ toDataURI { width = 100, height = 100 }
                    svgNodes
                ++ "\\")"
            )

-}
toDataURI : { width : Int, height : Int } -> List SvgNode -> String
toDataURI args list =
    let
        internalUrlEncode : String -> String
        internalUrlEncode string =
            string
                |> String.toList
                |> List.map
                    (\char ->
                        case char of
                            '<' ->
                                "%3C"

                            '>' ->
                                "%3E"

                            '"' ->
                                "%22"

                            '#' ->
                                "%23"

                            '\n' ->
                                ""

                            _ ->
                                String.fromChar char
                    )
                |> String.concat
    in
    "data:image/svg+xml,"
        ++ (list
                |> toString args
                |> internalUrlEncode
           )
        ++ ""


{-| convert the svg nodes into html.

Note: the svg will be displayed as the background of a div.

I tried converting it into a Svg node, but my browser didn't seem to like it.

Alternatively i looked into elm/Svg, but there i can't define custom attributes.

-}
toHtml : List (Attribute msg) -> { width : Int, height : Int } -> List SvgNode -> Html msg
toHtml attrs args list =
    Html.div
        ([ Html.Attributes.style "width" (String.fromInt args.width ++ "px")
         , Html.Attributes.style "height" (String.fromInt args.height ++ "px")
         , Html.Attributes.style "background-image" ("url(\"" ++ toDataURI args list ++ "\")")
         ]
            ++ attrs
        )
        []


type Msg
    = Download
    | SetBackgroundImage String


type alias Model =
    { background : String }


{-| A Program for viewing your Svg creations
-}
type alias Program =
    Platform.Program () Model Msg


{-| Convert into a program for viewing your Svg creations.

You might want to use this in combination with hot-loading, while you write your svg.

-}
toProgram : { name : String, width : Int, height : Int } -> List SvgNode -> Program
toProgram args list =
    let
        string =
            list |> toString { width = args.width, height = args.height }

        transparentBackground =
            [ rectangle { topLeft = ( 0, 0 ), width = 12, height = 12 }
                |> withFillColor "rgba(0,0,0,0.2)"
            , rectangle { topLeft = ( 12, 12 ), width = 12, height = 12 }
                |> withFillColor "rgba(0,0,0,0.2)"
            ]
                |> toDataURI { width = 24, height = 24 }
                |> (\s -> "url(\"" ++ s ++ "\")")
    in
    Browser.element
        { init = \() -> ( { background = transparentBackground }, Cmd.none )
        , view =
            \model ->
                [ list |> toHtml [ Html.Attributes.style "border" "1px dashed gray" ] { width = args.width, height = args.height }
                , [ "black"
                  , "white"
                  , "#eee"
                  , transparentBackground
                  ]
                    |> List.map
                        (\color ->
                            Html.button
                                [ Html.Attributes.style "width" "24px"
                                , Html.Attributes.style "height" "24px"
                                , Html.Attributes.style "background" color
                                , Html.Attributes.style "border" "1px solid gray"
                                , Html.Events.onClick (SetBackgroundImage color)
                                ]
                                []
                        )
                    |> (::)
                        (Html.button [ Html.Events.onClick Download ] [ Html.text "Download" ])
                    |> Html.div
                        [ Html.Attributes.style "display" "flex"
                        , Html.Attributes.style "flex-direction" "row"
                        , Html.Attributes.style "gap" "8px"
                        ]
                , Html.text string
                    |> List.singleton
                    |> Html.code
                        [ Html.Attributes.style "white-space" "pre"
                        , Html.Attributes.style "background" "#eee"
                        , Html.Attributes.style "padding" "8px"
                        , Html.Attributes.style "display" "flex"
                        ]
                , Html.node "style"
                    []
                    [ (":root{background : " ++ model.background ++ "}")
                        |> Html.text
                    ]
                ]
                    |> Html.div
                        [ Html.Attributes.style "display" "flex"
                        , Html.Attributes.style "flex-direction" "column"
                        , Html.Attributes.style "gap" "16px"
                        , Html.Attributes.style "padding" "16px"
                        ]
        , update =
            \msg model ->
                case msg of
                    Download ->
                        ( model, File.Download.string (args.name ++ ".svg") "image/svg+xml" string )

                    SetBackgroundImage background ->
                        ( { model | background = background }, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
