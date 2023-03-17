module Svg.Writer exposing (..)

import Html exposing (Attribute, Html)
import Html.Attributes
import Svg.Path exposing (Path)


type alias SvgAttribute =
    ( String, String )


type SvgNode
    = SvgNode
        { name : String
        , attributes : List ( String, String )
        , content : List SvgNode
        }


group : List SvgNode -> SvgNode
group list =
    SvgNode { name = "g", attributes = [], content = list }


defineMask : String -> List SvgNode -> SvgNode
defineMask id list =
    SvgNode
        { name = "mask"
        , attributes = [ ( "id", id ) ]
        , content = list
        }


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


use : String -> SvgNode
use id =
    SvgNode
        { name = "use"
        , attributes = [ ( "href", "#" ++ id ) ]
        , content = []
        }


withMask : String -> SvgNode -> SvgNode
withMask id =
    withAttribute ( "mask", "url(#" ++ id ++ ")" )


withNoFillColor : SvgNode -> SvgNode
withNoFillColor =
    withAttribute ( "fill", "none" )


withFillColor : String -> SvgNode -> SvgNode
withFillColor string =
    withAttribute ( "fill", string )


withNoStrokeColor : SvgNode -> SvgNode
withNoStrokeColor =
    withAttribute ( "stroke", "none" )


withStrokeColor : String -> SvgNode -> SvgNode
withStrokeColor string =
    withAttribute ( "stroke", string )


withStrokeWidth : Float -> SvgNode -> SvgNode
withStrokeWidth strokeWidth =
    withAttribute ( "stroke-width", String.fromFloat strokeWidth )


withAttribute : ( String, String ) -> SvgNode -> SvgNode
withAttribute attr (SvgNode svgNode) =
    { svgNode | attributes = attr :: svgNode.attributes }
        |> SvgNode


path : List SvgAttribute -> Path -> SvgNode
path attrs p =
    SvgNode
        { name = "path"
        , attributes = ( "d", Svg.Path.toString p ) :: attrs
        , content = []
        }


rectangle : List SvgAttribute -> { topLeft : ( Float, Float ), width : Float, height : Float } -> SvgNode
rectangle attrs args =
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
                ++ attrs
        , content = []
        }


circle : List SvgAttribute -> { radius : Float, pos : ( Float, Float ) } -> SvgNode
circle attrs args =
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
                ++ attrs
        , content = []
        }


toHtml : List (Attribute msg) -> List SvgNode -> Html msg
toHtml attrs list =
    let
        rec (SvgNode node) =
            Html.node node.name
                (node.attributes
                    |> List.map (\( name, value ) -> Html.Attributes.attribute name value)
                )
                (node.content |> List.map rec)
    in
    list
        |> List.map rec
        |> Html.node "svg" attrs


toString : { width : Float, height : Float } -> List SvgNode -> String
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
                        |> List.map (\( name, value ) -> name ++ "=" ++ value)
                        |> String.join " "
                   )
                ++ (if node.content == [] then
                        "/>\n"

                    else
                        ">\n"
                            ++ (node.content
                                    |> rec (depth + 1)
                                    |> String.concat
                               )
                            ++ (List.repeat (depth * 2) " "
                                    |> String.concat
                               )
                            ++ "</"
                            ++ node.name
                            ++ ">"
                   )
    in
    "<svg version=\"1.1\" \n    width=\""
        ++ String.fromFloat args.width
        ++ "\"\n    height=\""
        ++ String.fromFloat args.height
        ++ "\"\n    xmlns=\"http://www.w3.org/2000/svg\">\n"
        ++ (list |> List.map (rec 1) |> String.concat)
        ++ "</svg>"
