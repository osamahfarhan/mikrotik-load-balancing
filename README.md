# ----------- اصدار الميكروتيك V6

#:set ($InNames->("ether1"))  ({"speed"=2; "username"="USERNAME"; "password"="PASSWORE"; "ip"="192.168.10.1"});
# ----------- المنفد بدل 
#---------- ether1
# مثال
:set ($InNames->("ether13"))
# ----------- السرعة غير الرقم فقط
#---------- speed=2 
# ----------- اذاكان بردج غير 
#        USERNAME
#        PASSWORE
# مثال
#---------- "username"="A234342"; "password"="12345";
# ----------- اذا كان دمح عادي امسح اسم المستخدم وكلمة السر واكتب الايبي والسرعة
# مثال

:set ($InNames->("ether1"))  ({"speed"=2; "ip"="192.168.10.1"});

#  مثال على الدمج بردج
:set ($InNames->("ether1"))  ({ "speed"=2; "username"="A123"; "password"="123456"  });
:set ($InNames->("ether2"))  ({ "speed"=4; "username"="B123"; "password"="123456"  });
#  مثال على الدمج العادي
:set ($InNames->("ether2"))  ({ "speed"=4; "ip"="192.168.11.1" });
:set ($InNames->("ether3"))  ({ "speed"=8; "ip"="192.168.12.1" });
# اذا تريد تحذف الدمج 
:do {
/ip route remove  [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip firewall nat remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip firewall mangle remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/interface pppoe-client remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip address remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/interface list member remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/interface list remove [find where (name="DAMGPPP" || name="DMGWAN" || name="DMGLAN" || comment="Eng-Osamah-AutoLoadBalancing")];
}

#  انسخ السطر وكرر العملية
# {} انسخ كامل مع الاقواس 



:do {
:global InNames [:toarray ""];/terminal style varname-local;
:global InputErrorDo do={:if ([$1 $2 $3  i=$i]) do={/terminal style error;:do {/terminal style error;:put [$4 $2 i=$i];/terminal style escaped;:set $2 [/terminal ask value-name=[$3 $2 i=$i]];} while=([$1 $2 $3 $4 i=$i]);/terminal style escaped;};:return $2;}
/terminal style comment;
:put  ("Enter The number of Input Interfaces (2,3,4,5...50)")
:global InputLinesNumber [/terminal ask value-name="Number="];
:set $InputLinesNumber [$InputErrorDo (>[:return (([:tonum $1]+0)<=1||([:tonum $1]+0)>50)]) ($InputLinesNumber) (>[:return ("Enter Input Lines Number =")]) (>[:return ("invaled input $1 number of Input Interfaces ( 1 , 2 , 3 , 4 ... 50)")])];
/terminal style comment;
:put ("------ Start Output Interface------");
:global OutName [/terminal ask value-name="Enter The Output Interface name \r\n OutName="];
:set $OutName [$InputErrorDo (>[:return ([:len [/interface find where name=$1]]=0)]) ([:tostr $OutName]) (>[:return ("Enter Output interface Or Bridge name =")])  (>[:return ("No interface Named=$1")])];
:for i from=1 to=$InputLinesNumber do={  
    /terminal style comment;
    :put ("------ Start Line Number $i ------");
    /terminal style escaped;
    :local InType [/terminal ask value-name="Enter Input $i Interface type (  pppoe or ip ) \r\n Type=" ];
    :set $InType  [$InputErrorDo (>[:return (($1 != "pppoe"&&$1 != "ip"))]) ([:tostr $InType]) (>[:return ("Type=")]) (>[:return ("Invaled input $1 Enter The Type Interface (  pppoe or ip )")])  i=$i];
    /terminal style escaped;
    :local InName [/terminal ask value-name="Enter The Input Interface Name $i \r\n  name=" ];
    :set $InName  [$InputErrorDo (>[:return ([:len [/interface find where name=$1]]=0)]) ([:tostr $InName]) (>[:return ("Interface $i Name =")]) (>[:return "Invaled input Enter No interface Named=$1"])  i=$i];
    /terminal style escaped;
    :local InSpeed [/terminal ask value-name="Enter The Speed Of Interface Name $i Example ( 1 , 2 , 3 , 4 , 5 ....200)  \r\n speed=" ];
    :set $InSpeed [$InputErrorDo (>[:return (([:tonum $1]+0)<1||([:tonum $1]+0)>200)]) ($InSpeed) (>[:return ("Interface  $i speed=")]) (>[:return ("Invaled input $1 Enter The Speed Of Interface Name $i Example ( 1 , 2 , 3 , 4 , 5 ....200)")])  i=$i];
    :if ($InType = "ip") do={
    /terminal style escaped;
    :local InIp [/terminal ask value-name="Ip address of $InName Ip=" ];
    :set $InIp [$InputErrorDo (>[:return ([:len [:tostr [:toip $1]]]=0)]) ([:tostr $InIp]) (>[:return ("Ip address of $1  \r\n Ip=")]) (>[:return ("Invaled input ip $1 \r\n Example (192.168.1.1)")])  i=$i];
    :set ($InNames->("$InName")) ({"speed"=$InSpeed;"ip"=$InIp});
     } else={
    /terminal style escaped;:put "Enter The  pppoe username  of Interface $i $InName";
    :local pppoeUsername [/terminal ask value-name="Username="  ];
    /terminal style escaped;:put "Enter The pppoe password  of Interface $i $InName";
    :local pppoePassword [/terminal ask value-name="Password="];
    :set ($InNames->("$InName")) ({"speed"=$InSpeed;"username"=$pppoeUsername;"password"=$pppoePassword});
    };
    /terminal style comment;
    :put ("------ End Line Number $i ------");
};
:global OutNameB ("$OutName");
:global OutNameI ("$OutName");
:if ([:len [/interface bridge port find where interface=$OutName]]>0) do={:set $OutNameB [/interface bridge port get ([find where interface=$OutName]->0) bridge];:set $OutNameI $OutName;};
:if ([:len [/interface bridge find where name=$OutName]]>0) do={:set $OutNameI [/interface bridge port get ([find where bridge=$OutName]->0) interface];:set $OutNameB $OutName;};
:do {/interface list add comment="Eng-Osamah-AutoLoadBalancing" name=DAMGPPP;} on-error={};
:do {/interface list add comment="Eng-Osamah-AutoLoadBalancing" include=DAMGPPP name=DMGWAN;} on-error={};
:do {/interface list add comment="Eng-Osamah-AutoLoadBalancing" name=DMGLAN;} on-error={};
:do {/interface list member add interface=$OutNameB comment="Eng-Osamah-AutoLoadBalancing" list=DMGLAN;} on-error={};
:global ARR [:toarray ""];:global Total 0;:global Min 10000;:global Max 0;:global i 0;:global ALLPPP;:global ALLETH;
:foreach N,V in=$InNames do={
    :if ([:len [/interface find where name=$N]]=0) do={:error (" No interface Named=$N");:quit;}
    :if ($N=$OutNameI||$N=$OutNameB) do={:set ($InNames->$N);} else={
        :set $i ($i+1);
        :if (([:len ($V->("username"))]>0)&&([:len ($V->("username"))]>0)) do={
            :if ((($V->("username"))!="USERNAME") && (($V->("password"))!="PASSWORE")) do={
                :do {/interface list member add interface=$N comment="Eng-Osamah-AutoLoadBalancing" list=DMGWAN;} on-error={ };
                :do {/interface pppoe-client add disabled=yes interface=$N comment="Eng-Osamah-AutoLoadBalancing" keepalive-timeout=30 name=("pppoe-out-$i") user=($V->("username"))  password=($V->("password"));} on-error={ };
                :do {/interface list member add interface=("pppoe-out-$i") comment="Eng-Osamah-AutoLoadBalancing" list=DAMGPPP;} on-error={};
                :set $ALLPPP ($ALLPPP,("pppoe-out-$i"));
                :set ($InNames->$N->("R")) ("pppoe-out-$i");
            } else={:set ($InNames->$N);:set $i ($i-1);};
        } else={
            :if (([:len ($V->("ip"))]>0)) do={
                :local ip [:toip ($V->("ip"))];
                :if ([:len [:tostr $ip]]=0) do={:error ("not correct ip".($V->("ip")));};
                :local wip $ip;
                :if ((($ip)&(0.0.0.255))>(0.0.0.250)) do={:set $wip ($wip-1);} else={:set $wip ($wip+1);};
                :foreach i in=$ALLETH do={:if ($i=$wip) do={:set $wip ($wip+1);};};
                :do {/interface list member add interface=$N comment="Eng-Osamah-AutoLoadBalancing" list=DMGWAN;} on-error={ };
                :do {/ip address add interface=$N comment="Eng-Osamah-AutoLoadBalancing" address=($wip."/24");} on-error={ };
                :set $ALLETH ($ALLETH,$ip);
                :set ($InNames->$N->("R")) $ip;
            } else={:set ($InNames->$N);:set $i ($i-1);};
        }
    }
}
:global ALLOUT ($ALLETH,$ALLPPP);:global LINES ([:len $ALLOUT]);:set $i 0;
:foreach N,V in=$InNames do={:local j ($V->("speed"));:if ($j=0) do={:error ("not correct speed");};:set $Total ($Total+$j);:if ($j<$Min) do={:set $Min $j;};:if ($j>$Max) do={:set $Max $j;};};
:if ($Total=0 || $Min=0 || $Max=0) do={:error "not correct number";} 
:global Con (($Total/$Min));:global ConN 0;
:do {/ip route add disabled=yes gateway=$ALLOUT comment="Eng-Osamah-AutoLoadBalancing";} on-error={};
:do {/ip firewall nat add action=masquerade disabled=yes chain=srcnat out-interface-list=DMGWAN comment="Eng-Osamah-AutoLoadBalancing";} on-error={};
:do {/ip firewall nat add action=masquerade disabled=yes chain=srcnat out-interface-list=("pppoe-out") comment="Eng-Osamah-AutoLoadBalancing";} on-error={};
:set $i 0;
/ip firewall mangle add action=accept chain=prerouting hotspot=!auth,from-client protocol=tcp port=80,443,8080 comment="Eng-Osamah-AutoLoadBalancing";
/ip firewall mangle add action=accept chain=prerouting dst-address-type=local port=80,443,8080 comment="Eng-Osamah-AutoLoadBalancing";
:foreach N,V in=$InNames do={
:local j ($V->("speed"));:set $i ($i+1);:local n ($j/$Min);:if ($n=0) do={:set $n 1;};
:for k from=1 to=$n do={/ip firewall mangle add comment="Eng-Osamah-AutoLoadBalancing" disabled=yes action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface-list=DMGLAN new-connection-mark=("C_$i") passthrough=yes per-connection-classifier=("both-addresses-and-ports:$Con/$ConN");:set $ConN ($ConN+1);};
:if ($LINES=$i) do={/ip firewall mangle add comment="Eng-Osamah-AutoLoadBalancing" disabled=yes action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface-list=DMGLAN new-connection-mark=("C_$i") passthrough=yes;:set $ConN ($ConN+1);};
/ip firewall mangle add comment="Eng-Osamah-AutoLoadBalancing" disabled=yes action=mark-routing chain=prerouting connection-mark=("C_$i") in-interface-list=DMGLAN new-routing-mark=("R_$i") passthrough=no;
/ip route add comment="Eng-Osamah-AutoLoadBalancing" disabled=yes gateway=($V->("R")) routing-mark=("R_$i");
};
/ip route enable  [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip firewall nat enable [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip firewall mangle enable [find where comment="Eng-Osamah-AutoLoadBalancing"];
/interface pppoe-client enable [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip address enable [find where comment="Eng-Osamah-AutoLoadBalancing"];
};
