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

%% API
-export([print_events/1, count_measurements/1, dom/1, callback/2, react_for_events/1, parse_from_dom/1, bind/2]).



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
    startDocument -> io:format("Rozpoczynamy przetwarzanie dokumentu");
    {startElement, _, "date", _, _} -> io:format("Data");
    {startElement, _, "time", _, _} -> io:format("Czas");
    {startElement, _, "x", _, _} -> io:format("Pierwsza współrzędna");
    {startElement, _, "y", _, _} -> io:format("Druga współrzędna");
    {startElement, _, "value", _, _} -> io:format("Poziom zanieczyszczen");
    {endElement, _, "date", _, _} -> io:format("Data - zamkniecie tagu");
    {endElement, _, "time", _, _} -> io:format("Czas - zamkniecie tagu");
    {endElement, _, "x", _, _} -> io:format("Pierwsza współrzędna - zamkniecie tagu");
    {endElement, _, "y", _, _} -> io:format("Druga współrzędna - zamkniecie tagu");
    {endElement, _, "value", _, _} -> io:format("Poziom zanieczyszczen - zamkniecie tagu");
    {characters, _Characters} -> io:format("~p~n", [State]);
    endDocument -> io:format("Zakończyliśmy przetwarzanie dokumentu")
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


