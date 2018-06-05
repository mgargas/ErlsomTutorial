# ErlsomTutorial

```
erlsom_tutorial:print_events("pollution_1.xml"). 
```

```
erlsom_tutorial:count_measurements("pollution.xml"). 
```

```
erlsom_tutorial:react_for_events("pollution_1.xml").
```

```
DOM = erlsom_tutorial:dom("pollution_1.xml").
```

```
erlsom_tutorial:parse_from_dom(DOM). 
```

```
BIND = erlsom_tutorial:bind("pollution_1.xml", "pollution.xsd").
```

```
erlsom:write_xsd_hrl_file("pollution.xsd", "head.hrl"). 
```
```
-include("head.hrl").
```

```
erlsom_tutorial:bind_test(BIND).
```

```
erlsom_tutorial:bind_test2(BIND).
```