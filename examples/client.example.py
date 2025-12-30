# Python Example - PersistenceAI API Client
# This file demonstrates Python integration

class PersistenceAIClient:
    def __init__(self, base_url: str = "http://localhost:4096"):
        self.base_url = base_url
    
    def create_session(self, directory: str):
        """Create a new PersistenceAI session"""
        return {"session_id": "new_session", "directory": directory}

if __name__ == "__main__":
    client = PersistenceAIClient()
    print(client.create_session("/path/to/project"))
