// Go Example - PersistenceAI CLI
// This file demonstrates Go integration

package main

import "fmt"

type Config struct {
    Provider string
    Model    string
}

func main() {
    config := Config{
        Provider: "anthropic",
        Model:    "claude-sonnet-4",
    }
    fmt.Printf("PersistenceAI Config: %+v\n", config)
}
