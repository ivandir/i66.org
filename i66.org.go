package main

import (
    "fmt"
    "io"
    "net/http"
    "os"
    "os/exec"
    "strings"
)

const baseURL = "http://i66.org/"

var version = "dev"

func main() {
    if len(os.Args) == 2 && (os.Args[1] == "-v" || os.Args[1] == "--version") {
        fmt.Printf("i66 %s\n", version)
        return
    }

    if len(os.Args) != 2 {
        fmt.Println("Usage: i66 <command>")
        os.Exit(1)
    }

    cmdName := strings.Trim(os.Args[1], "/")
    url := baseURL + cmdName

    resp, err := http.Get(url)
    if err != nil {
        fmt.Printf("Error fetching %s: %v\n", url, err)
        os.Exit(1)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        fmt.Printf("Error: HTTP %d from %s\n", resp.StatusCode, url)
        os.Exit(1)
    }

    body, err := io.ReadAll(resp.Body)
    if err != nil {
        fmt.Printf("Error reading response: %v\n", err)
        os.Exit(1)
    }

    // The body is assumed to be a shell command
    shellCommand := strings.TrimSpace(string(body))
    fmt.Printf("Executing: %s\n", shellCommand)

    cmd := exec.Command("bash", "-c", shellCommand)
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    err = cmd.Run()
    if err != nil {
        fmt.Printf("Error executing command: %v\n", err)
        os.Exit(1)
    }
}
