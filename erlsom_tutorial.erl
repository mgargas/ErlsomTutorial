%%%-------------------------------------------------------------------
%%% @author marek
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jun 2018 21:53
%%%-------------------------------------------------------------------
-module(erlsom_tutorial).
-author("marek").

-include("head.hrl").

%% API
-export([print_events/1, count_measurements/1, dom/1, callback/2, react_for_events/1, parse_from_dom/1, bind/2, bind_test/1, bind_test2/1, parse_params/1]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAX_PARSER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_events(File) ->
  {ok, Handler} = file:read_file(File),
  erlsom:parse_sax(Handler, [], fun(Event, Acc) -> io:format("~p~n", [Event]), Acc end).


count_measurements(File) ->
  {ok, Handler} = file:read_file(File),
  CountMeasurements = fun(Event, Acc) -> case Event of {startElement, _, "measurement", _, _} -> Acc + 1; _ -> Acc end end,
  erlsom:parse_sax(Handler, 0, CountMeasurements).


react_for_events(File) ->
  {ok, Handler} = file:read_file(File),
  erlsom:parse_sax(Handler, [], fun callback/2).


callback(Event, State) ->
  case Event of
    startDocument -> io:format("Rozpoczynamy przetwarzanie dokumentu.~n");
    {startElement,[],"document",[],[]} -> io:format("Document: ~n");
    {startElement, _, "measurement", _, _} -> io:format("Pomiar: ~n");
    {startElement, _, "date", _, _} -> io:format("Data: ");
    {startElement, _, "time", _, _} -> io:format("Czas: ");
    {startElement, _, "x", _, _} -> io:format("Pierwsza współrzędna: ");
    {startElement, _, "y", _, _} -> io:format("Druga współrzędna: ");
    {startElement, _, "value", _, _} -> io:format("Poziom zanieczyszczen: ");
    {endElement, _, "document", _} -> io:format("Dokument - zamkniecie tagu.~n");
    {endElement, _, "measurement", _} -> io:format("Pomiar - zamkniecie tagu.~n");
    {endElement, _, "date", _} -> io:format("Data - zamkniecie tagu.~n");
    {endElement, _, "time", _} -> io:format("Czas - zamkniecie tagu.~n");
    {endElement, _, "x", _} -> io:format("Pierwsza współrzędna - zamkniecie tagu.~n");
    {endElement, _, "y", _} -> io:format("Druga współrzędna - zamkniecie tagu.~n");
    {endElement, _, "value", _} -> io:format("Poziom zanieczyszczen - zamkniecie tagu.~n");
    {characters, _Characters} -> io:format("~p~n", [_Characters]);
    endDocument -> io:format("Zakończyliśmy przetwarzanie dokumentu.~n");
    {processingInstruction,_, _} -> io:format("Przetwarzanie instrukcji.~n");
    {ignorableWhitespace,_} -> io:format("");
    _ -> io:format("Jeszcze coś innego.~n")

end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DOM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dom(File) ->
  {ok, Handler} = file:read_file(File),
  erlsom:simple_form(Handler).


parse_from_dom(DOM) ->
  Measurements_list = element(3, element(2, DOM)),
  lists:map(
    fun ({Tag, Attr, Elements}) ->
      maps:from_list(lists:map(fun({T, A, E}) -> {T, lists:flatten(E)} end, Elements)) end,
    Measurements_list).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data binder $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

bind(Xml_file, Model_file) ->
  {ok, Xml} = file:read_file(Xml_file),
  {ok, Model} = erlsom:compile_xsd_file(Model_file),
  {ok, Result, _} = erlsom:scan(Xml, Model),
  Result.

bind_test(BIND) ->
  MeasurementsList = BIND#document.measurement,
  MeasurementsList.

bind_test2(BIND) ->
  MeasurementsList = BIND#document.measurement,
  [H | T] = MeasurementsList,

  io:format("Data: ~p~n", [H#'document/measurement'.date]),
  io:format("Time: ~p~n", [H#'document/measurement'.time]),
  io:format("x: ~p~n", [H#'document/measurement'.x]),
  io:format("y: ~p~n", [H#'document/measurement'.y]),
  io:format("Value: ~p~n", [H#'document/measurement'.value]).

parse_params(Head) ->

  Head#'document/measurement'{ value = element(1, string:to_integer(Head#'document/measurement'.value)),
    x = element(1, string:to_float(Head#'document/measurement'.x)),
    y = element(1, string:to_float(Head#'document/measurement'.y)),
    time = list_to_tuple(lists:map(fun (X)-> element(1,string:to_integer(X)) end, (string:split(Head#'document/measurement'.time, ":")))),
    date = list_to_tuple(lists:reverse(lists:map(fun (X)-> element(1,string:to_integer(X)) end, (string:split(Head#'document/measurement'.date, "-", all)))))}.






