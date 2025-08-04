# **Zero-Knowledge Proof Based Authenticator**

A secure authentication system implemented in Rust that uses Zero-Knowledge Proofs (ZKP) to authenticate users without revealing their passwords. The system is built using gRPC for client-server communication and implements the Schnorr identification protocol.

## Overview

This project implements a cryptographically secure authentication system where users can prove they know a secret (password) without actually revealing it to the server. The system uses discrete logarithm-based zero-knowledge proofs, specifically the Schnorr identification protocol, to ensure password privacy and security.

## Features

- **Zero-Knowledge Authentication**: Users prove password knowledge without revealing actual passwords
- **Schnorr Protocol Implementation**: Uses cryptographically sound discrete logarithm proofs
- **gRPC Communication**: High-performance, type-safe client-server communication
- **Secure Random Generation**: Cryptographically secure random number generation
- **Session Management**: Server-side session tracking after successful authentication
- **Multi-bit Security**: Supports both 1024-bit and 2048-bit cryptographic parameters

## Cryptographic Foundation

### Protocol Overview
The system implements the Schnorr identification protocol:

1. **Registration Phase**: 
   - User generates `y1 = α^x mod p` and `y2 = β^x mod p`
   - Sends `(y1, y2)` to server (public values)

2. **Challenge Phase**:
   - User generates random `k` and computes `r1 = α^k mod p`, `r2 = β^k mod p`
   - Server responds with random challenge `c`

3. **Response Phase**:
   - User computes `s = k - c * x mod q`
   - Server verifies: `r1 = α^s * y1^c mod p` and `r2 = β^s * y2^c mod p`

### Security Parameters
- **1024-bit constants**: Based on RFC 5114 recommendations
- **2048-bit constants**: Enhanced security for sensitive applications
- **Prime field operations**: All computations in secure prime fields
- **Discrete logarithm hardness**: Security based on computational difficulty

## 📋 Project Structure

```
zkp-auth/
├── proto/
│   └── zkp_auth.proto         # Protocol Buffer definitions
├── src/
│   ├── lib.rs                 # ZKP core implementation
│   ├── server.rs              # gRPC server implementation
│   ├── client.rs              # gRPC client implementation
│   └── zkp_auth.rs            # Generated gRPC code
├── target/                    # Build artifacts and cache
│   ├── .rustc_info.json
│   ├── CACHEDIR.TAG
│   └── ...
├── build.rs                   # Build script for Protocol Buffers
├── Cargo.toml                 # Rust dependencies and metadata
├── Cargo.lock                 # Dependency lock file
├── docker-compose.yml         # Docker containerization setup
├── Dockerfile                 # Docker image configuration
└── README.md                  # Project documentation
```

## Technology Stack

- **Rust**: Systems programming language for performance and safety
- **Tonic**: gRPC framework for Rust
- **Protocol Buffers**: Interface definition and serialization
- **num-bigint**: Arbitrary precision integer arithmetic
- **tokio**: Asynchronous runtime
- **rand**: Cryptographically secure random number generation

## Dependencies

```toml
[dependencies]
tonic = "0.10"
tokio = { version = "1.0", features = ["macros", "rt-multi-thread"] }
prost = "0.12"
num-bigint = { version = "0.4", features = ["rand"] }
rand = "0.8"
hex = "0.4"

[build-dependencies]
tonic-build = "0.10"
```

## Getting Started

### Prerequisites

- Rust 1.70 or higher
- Protocol Buffer compiler (`protoc`)
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd zkp-auth
```

2. Install dependencies:
```bash
cargo build
```

3. Generate gRPC code (if needed):
```bash
cargo build  # This will trigger build.rs to generate gRPC code
```

### Running the System

#### 1. Start the Server
```bash
cargo run --bin server
```
The server will start on `127.0.0.1:50051`

#### 2. Run the Client
```bash
cargo run --bin client
```

Follow the interactive prompts:
1. Enter username
2. Enter password (for registration)
3. Enter password again (for authentication)

## Usage Example

### Registration Flow
```rust
// User computes public values
let (y1, y2) = zkp.compute_pair(&password);

// Send registration request
let request = RegisterRequest {
    user: username,
    y1: y1.to_bytes_be(),
    y2: y2.to_bytes_be(),
};
```

### Authentication Flow
```rust
// 1. Challenge Request
let k = ZKP::generate_random_number_below(&q);
let (r1, r2) = zkp.compute_pair(&k);

let request = AuthenticationChallengeRequest {
    user: username,
    r1: r1.to_bytes_be(),
    r2: r2.to_bytes_be(),
};

// 2. Challenge Response
let s = zkp.solve(&k, &c, &password);

let request = AuthenticationAnswerRequest {
    auth_id,
    s: s.to_bytes_be(),
};
```

## API Reference

### Core ZKP Methods

#### `compute_pair(exp: &BigUint) -> (BigUint, BigUint)`
Computes `(α^exp mod p, β^exp mod p)` for registration and challenge phases.

#### `solve(k: &BigUint, c: &BigUint, x: &BigUint) -> BigUint`
Computes the zero-knowledge proof response `s = k - c * x mod q`.

#### `verify(r1, r2, y1, y2, c, s) -> bool`
Verifies the zero-knowledge proof by checking:
- `r1 = α^s * y1^c mod p`
- `r2 = β^s * y2^c mod p`

### gRPC Services

#### `Register(RegisterRequest) -> RegisterResponse`
Registers a new user with public values `y1` and `y2`.

#### `CreateAuthenticationChallenge(AuthenticationChallengeRequest) -> AuthenticationChallengeResponse`
Initiates authentication by sending `r1`, `r2` and receiving challenge `c`.

#### `VerifyAuthentication(AuthenticationAnswerRequest) -> AuthenticationAnswerResponse`
Completes authentication by verifying the zero-knowledge proof response.

## Testing

Run the comprehensive test suite:
```bash
cargo test
```

### Test Categories

1. **Toy Example Tests**: Simple numeric examples for algorithm verification
2. **1024-bit Tests**: Standard security parameter testing
3. **2048-bit Tests**: Enhanced security testing
4. **Random Number Tests**: Cryptographic randomness validation

### Example Test
```rust
#[test]
fn test_toy_example() {
    let zkp = ZKP { /* ... */ };
    let (y1, y2) = zkp.compute_pair(&x);
    let (r1, r2) = zkp.compute_pair(&k);
    let s = zkp.solve(&k, &c, &x);
    assert!(zkp.verify(&r1, &r2, &y1, &y2, &c, &s));
}
```
