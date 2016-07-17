package main

import (
    "net/http"
    "net/url"
    "strings"
    "fmt"
    "os"
)


// Manual update:
// ./sendToCuberiteServer update server66 ipv4 6.6.6.6

func main() {
    fmt.Println("sendToCuberiteServer")


    action := os.Args[1]
    name := os.Args[2]
    field := os.Args[3]
    value := os.Args[4]

    data := url.Values{
        "action":       {action},
        "name":         {name},
        "field":        {field},
        "value":        {value},
        }

    CuberiteServerRequest(data)
}


// Post URL:
// http://127.0.0.1:8080/webadmin/GandiCraft/Gandi?action=update&name=server01&field=ipv4&value=7.77.7.7

func CuberiteServerRequest(data url.Values) {
    client := &http.Client{}
    req, _ := http.NewRequest("POST", "http://127.0.0.1:8080/webadmin/GandiCraft/Gandi", strings.NewReader(data.Encode()))
    req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
    req.SetBasicAuth("admin", "admin")
    client.Do(req)
}
