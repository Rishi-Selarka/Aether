import Foundation

/// Static pre-authored MCQ question bank.
/// 18 generic blocks × 3 + 23 specific blocks × 3 = 123 questions total.
/// correctIndex distribution: ~31 each for indices 0-3.
/// All options are 25-60 characters with similar lengths per question.
enum QuizContent {

    // MARK: - Public API

    /// Returns 3 questions for the given block type in the given problem.
    /// Falls back to generic block questions if no problem-specific override exists.
    /// Options are always shuffled to eliminate position bias.
    static func questions(for nodeType: NodeType, problemID: String) -> [QuizQuestion] {
        let key = "\(problemID)_\(nodeType.rawValue)"
        let raw = specificQuestions[key] ?? genericQuestions[nodeType] ?? []
        return raw.map { $0.withShuffledOptions() }
    }

    // MARK: - Generic Questions (fallback per block type)

    // correctIndex distribution across 54 generic questions:
    // 0: 14, 1: 14, 2: 13, 3: 13

    private static let genericQuestions: [NodeType: [QuizQuestion]] = [

        // MARK: UI (indices: 2, 0, 3)
        .ui: [
            QuizQuestion(id: "gen_ui_1", blockType: .ui,
                questionText: "What happens if a SwiftUI View directly mutates a data model?",
                options: [
                    "The view recomputes its body method",
                    "Bindings propagate to all observers",
                    "It bypasses tracking and breaks updates",
                    "SwiftUI merges it with pending updates"
                ],
                correctIndex: 2,
                explanation: "Direct mutation bypasses SwiftUI's observation system. Changes must flow through @Published or @Bindable to trigger view updates."),
            QuizQuestion(id: "gen_ui_2", blockType: .ui,
                questionText: "Why should a SwiftUI View avoid holding business logic?",
                options: [
                    "Logic in views cannot be unit tested",
                    "Views re-render too slowly with logic",
                    "SwiftUI compiler rejects such patterns",
                    "Business logic causes accessibility bugs"
                ],
                correctIndex: 0,
                explanation: "Views are tightly coupled to the UI framework, making embedded logic impossible to test without a full UI host."),
            QuizQuestion(id: "gen_ui_3", blockType: .ui,
                questionText: "When should a View use @StateObject instead of @ObservedObject?",
                options: [
                    "When the data comes from a parent view",
                    "When the object is shared across scenes",
                    "When the view owns the object lifecycle",
                    "When observing environment key paths"
                ],
                correctIndex: 2,
                explanation: "@StateObject ensures SwiftUI creates the object once and preserves it across re-renders, unlike @ObservedObject which expects external ownership."),
        ],

        // MARK: ViewModel (indices: 1, 3, 0)
        .viewModel: [
            QuizQuestion(id: "gen_vm_1", blockType: .viewModel,
                questionText: "What problem does a ViewModel solve that a plain model cannot?",
                options: [
                    "It stores data more efficiently in RAM",
                    "It transforms raw data for display needs",
                    "It handles network calls automatically",
                    "It persists state across app launches"
                ],
                correctIndex: 1,
                explanation: "ViewModels transform raw domain data into display-ready state, keeping Views free of formatting and transformation logic."),
            QuizQuestion(id: "gen_vm_2", blockType: .viewModel,
                questionText: "Why should a ViewModel never import SwiftUI directly?",
                options: [
                    "SwiftUI types consume too much memory",
                    "Apple guidelines prohibit this import",
                    "It couples logic to a specific UI layer",
                    "It would create a circular dependency"
                ],
                correctIndex: 2,
                explanation: "Importing SwiftUI binds the ViewModel to one UI framework, preventing unit testing and reuse across platforms."),
            QuizQuestion(id: "gen_vm_3", blockType: .viewModel,
                questionText: "In MVVM, which layer should decide when to fetch fresh data?",
                options: [
                    "The Repository on a fixed time interval",
                    "The View during its onAppear lifecycle",
                    "The ViewModel based on staleness rules",
                    "The database when its cache size grows"
                ],
                correctIndex: 2,
                explanation: "The ViewModel owns the decision of when data is stale and needs refreshing, coordinating between View lifecycle events and Repository capabilities."),
        ],

        // MARK: Database (indices: 3, 1, 2)
        .database: [
            QuizQuestion(id: "gen_db_1", blockType: .database,
                questionText: "Why does SwiftData use @Model classes instead of plain structs?",
                options: [
                    "Structs cannot conform to Identifiable",
                    "Classes allow lazy property evaluation",
                    "Structs are too slow for disk operations",
                    "Classes enable change tracking via refs"
                ],
                correctIndex: 3,
                explanation: "SwiftData relies on reference semantics to observe property changes and sync them to the persistent store automatically."),
            QuizQuestion(id: "gen_db_2", blockType: .database,
                questionText: "What is the main risk of performing database queries on the main thread?",
                options: [
                    "Queries return nil on the main thread",
                    "Long queries freeze the user interface",
                    "The database locks for all other reads",
                    "SwiftData throws a runtime assertion"
                ],
                correctIndex: 1,
                explanation: "Blocking the main thread with slow queries causes UI hitches and dropped frames, degrading the user experience."),
            QuizQuestion(id: "gen_db_3", blockType: .database,
                questionText: "When should you use a cascade delete rule in SwiftData?",
                options: [
                    "When child objects share many parents",
                    "When deletions must be reversible later",
                    "When children have no meaning alone",
                    "When storage space is not a concern"
                ],
                correctIndex: 2,
                explanation: "Cascade deletes ensure dependent child objects are removed when their parent is deleted, preventing orphaned records."),
        ],

        // MARK: API (indices: 0, 2, 1)
        .api: [
            QuizQuestion(id: "gen_api_1", blockType: .api,
                questionText: "Why should an API layer return domain models, not raw JSON?",
                options: [
                    "JSON decoding is faster with raw types",
                    "It shields callers from format changes",
                    "Domain models cannot be serialized back",
                    "Apple requires Codable for all models"
                ],
                correctIndex: 1,
                explanation: "Mapping JSON to domain models at the API boundary means upstream code is unaffected when the server response format changes."),
            QuizQuestion(id: "gen_api_2", blockType: .api,
                questionText: "What is the primary benefit of defining API routes as an enum?",
                options: [
                    "Enums use less memory than struct types",
                    "String URLs are simpler to maintain well",
                    "The compiler enforces all cases are valid",
                    "Enums automatically retry failed calls"
                ],
                correctIndex: 2,
                explanation: "An enum-based router lets the compiler verify every route is handled, eliminating typos and missing endpoints at build time."),
            QuizQuestion(id: "gen_api_3", blockType: .api,
                questionText: "Why should API error handling distinguish network vs. server errors?",
                options: [
                    "Server errors need shorter timeout values",
                    "Network errors may succeed on retry soon",
                    "They always require the same user message",
                    "Server errors never contain useful data"
                ],
                correctIndex: 1,
                explanation: "Network errors are often transient (airplane mode, timeout) and worth retrying, while server errors (500, 404) indicate a different class of problem."),
        ],

        // MARK: Repository (indices: 2, 0, 3)
        .repository: [
            QuizQuestion(id: "gen_repo_1", blockType: .repository,
                questionText: "What pattern does a Repository implement between data sources?",
                options: [
                    "It duplicates data across all sources",
                    "It exposes each source to the ViewModel",
                    "It abstracts sources behind one interface",
                    "It routes reads to network writes to disk"
                ],
                correctIndex: 2,
                explanation: "The Repository pattern hides whether data comes from network, cache, or database behind a single clean interface."),
            QuizQuestion(id: "gen_repo_2", blockType: .repository,
                questionText: "Why should a Repository use a protocol rather than a concrete class?",
                options: [
                    "Swift requires protocols for async methods",
                    "Concrete classes crash in unit test runs",
                    "Protocols allow swapping implementations",
                    "Protocols reduce the binary size overall"
                ],
                correctIndex: 2,
                explanation: "Protocol-based repositories let you swap in mock implementations for testing and alternate backends for different environments."),
            QuizQuestion(id: "gen_repo_3", blockType: .repository,
                questionText: "When should a Repository bypass cache and hit the network directly?",
                options: [
                    "Every time the app returns to foreground",
                    "When the user has a fast WiFi connection",
                    "When cache data has exceeded a size limit",
                    "When a user explicitly triggers a refresh"
                ],
                correctIndex: 3,
                explanation: "User-initiated refresh (pull-to-refresh) is a clear signal to bypass stale cache data and fetch directly from the network."),
        ],

        // MARK: NetworkCache (indices: 1, 3, 0)
        .networkCache: [
            QuizQuestion(id: "gen_nc_1", blockType: .networkCache,
                questionText: "What determines when a network cache entry should be invalidated?",
                options: [
                    "The total size of the cache on disk now",
                    "The TTL or staleness policy of the entry",
                    "Whether the device has available storage",
                    "How many times the entry has been read"
                ],
                correctIndex: 1,
                explanation: "Time-to-live (TTL) policies ensure cached responses are refreshed after a defined period, balancing freshness against performance."),
            QuizQuestion(id: "gen_nc_2", blockType: .networkCache,
                questionText: "Why is a stale-while-revalidate strategy useful for caching?",
                options: [
                    "It prevents any stale data from showing",
                    "It eliminates the need for network access",
                    "It blocks UI until fresh data has arrived",
                    "It serves cached data while updating async"
                ],
                correctIndex: 3,
                explanation: "Stale-while-revalidate shows cached data immediately for fast UI, then silently fetches fresh data in the background."),
            QuizQuestion(id: "gen_nc_3", blockType: .networkCache,
                questionText: "What risk does an unbounded network cache introduce over time?",
                options: [
                    "Disk usage grows until storage runs out",
                    "Network requests become slightly faster",
                    "The operating system throttles the cache",
                    "Cache hits start returning wrong entries"
                ],
                correctIndex: 0,
                explanation: "Without eviction policies (LRU, max size), a cache will consume increasing disk space, eventually impacting device storage."),
        ],

        // MARK: MemoryCache (indices: 0, 2, 1)
        .memoryCache: [
            QuizQuestion(id: "gen_mc_1", blockType: .memoryCache,
                questionText: "Why does a memory cache use NSCache instead of a plain Dictionary?",
                options: [
                    "NSCache auto-evicts under memory pressure",
                    "Dictionaries cannot hold reference types",
                    "NSCache supports Codable encoding natively",
                    "Dictionaries cause threading deadlocks"
                ],
                correctIndex: 0,
                explanation: "NSCache cooperates with the system's memory management, automatically removing entries when the device is low on RAM."),
            QuizQuestion(id: "gen_mc_2", blockType: .memoryCache,
                questionText: "What is the main trade-off of a large memory cache limit?",
                options: [
                    "Disk I/O increases proportionally to size",
                    "Lookup speed degrades with more entries",
                    "Other app features receive less free RAM",
                    "The OS forces the cache to use swap files"
                ],
                correctIndex: 2,
                explanation: "A large memory cache consumes RAM that other app features need, potentially leading to memory warnings and termination."),
            QuizQuestion(id: "gen_mc_3", blockType: .memoryCache,
                questionText: "When should you prefer memory cache over disk-based cache?",
                options: [
                    "When data must persist across app launch",
                    "When sub-millisecond access speed matters",
                    "When caching files larger than fifty megs",
                    "When data changes less than once per week"
                ],
                correctIndex: 1,
                explanation: "Memory cache provides near-instant access suitable for frequently read, easily re-derivable data like decoded images or computed layouts."),
        ],

        // MARK: BackgroundWorker (indices: 3, 1, 2)
        .backgroundWorker: [
            QuizQuestion(id: "gen_bw_1", blockType: .backgroundWorker,
                questionText: "Why must a background worker avoid updating UI state directly?",
                options: [
                    "Background threads have lower CPU priority",
                    "The OS throttles background UI operations",
                    "UI frameworks are not compiled for threads",
                    "UIKit and SwiftUI require main thread only"
                ],
                correctIndex: 3,
                explanation: "UI frameworks are single-threaded by design. Background updates must dispatch to the main thread to avoid undefined behavior and crashes."),
            QuizQuestion(id: "gen_bw_2", blockType: .backgroundWorker,
                questionText: "What problem does structured concurrency solve for background tasks?",
                options: [
                    "It makes all tasks run at the same speed",
                    "It ensures child tasks cancel with parent",
                    "It replaces the need for async/await calls",
                    "It merges results from all tasks into one"
                ],
                correctIndex: 1,
                explanation: "Structured concurrency ties child task lifetimes to their parent, so cancelling a parent automatically cancels all its children."),
            QuizQuestion(id: "gen_bw_3", blockType: .backgroundWorker,
                questionText: "When should a background worker use a serial queue over concurrent?",
                options: [
                    "When tasks are completely independent",
                    "When maximum throughput is the top goal",
                    "When tasks must execute in strict order",
                    "When each task takes under one millisecond"
                ],
                correctIndex: 2,
                explanation: "Serial queues guarantee ordered execution, essential when tasks depend on results of previous tasks or modify shared state."),
        ],

        // MARK: ImageCache (indices: 1, 0, 3)
        .imageCache: [
            QuizQuestion(id: "gen_ic_1", blockType: .imageCache,
                questionText: "Why should an image cache store decoded bitmaps, not raw file data?",
                options: [
                    "Raw data takes less memory to store well",
                    "Decoded bitmaps skip costly re-decoding",
                    "File data cannot be stored in NSCache obj",
                    "Bitmaps compress better than source files"
                ],
                correctIndex: 1,
                explanation: "Decoding JPEG/PNG to bitmaps is expensive. Caching the decoded result avoids repeating this work on each display."),
            QuizQuestion(id: "gen_ic_2", blockType: .imageCache,
                questionText: "What strategy prevents an image cache from exhausting device memory?",
                options: [
                    "An LRU eviction policy with a size limit",
                    "Converting all images to text descriptions",
                    "Storing images only in the database layer",
                    "Loading all images during app launch only"
                ],
                correctIndex: 0,
                explanation: "LRU (least recently used) eviction combined with a max byte limit ensures the cache stays within safe memory bounds."),
            QuizQuestion(id: "gen_ic_3", blockType: .imageCache,
                questionText: "Why use a two-tier image cache with memory and disk layers?",
                options: [
                    "Disk caches are faster than memory caches",
                    "Memory caches persist across app launches",
                    "One tier makes the code simpler to manage",
                    "Memory gives speed and disk gives survival"
                ],
                correctIndex: 3,
                explanation: "Memory provides instant access for visible images; disk persists across launches so images survive app termination without re-downloading."),
        ],

        // MARK: LazyLoader (indices: 2, 3, 0)
        .lazyLoader: [
            QuizQuestion(id: "gen_ll_1", blockType: .lazyLoader,
                questionText: "What is the core principle behind lazy loading in mobile apps?",
                options: [
                    "Load everything at launch for fast access",
                    "Pre-fetch all data before the user scrolls",
                    "Defer work until the moment it is needed",
                    "Cache every result permanently on the disk"
                ],
                correctIndex: 2,
                explanation: "Lazy loading defers expensive operations (network calls, image decoding) until the result is actually needed, reducing startup time and memory use."),
            QuizQuestion(id: "gen_ll_2", blockType: .lazyLoader,
                questionText: "How does a lazy loader improve perceived scroll performance?",
                options: [
                    "It disables animations during fast scrolls",
                    "It reduces the frame rate to save battery",
                    "It skips loading items the user scrolled by",
                    "It loads upcoming items before they appear"
                ],
                correctIndex: 3,
                explanation: "Pre-fetching items just ahead of the visible area ensures content is ready before the user scrolls to it, avoiding blank cells."),
            QuizQuestion(id: "gen_ll_3", blockType: .lazyLoader,
                questionText: "What risk does lazy loading introduce if not handled carefully?",
                options: [
                    "Content may flash or shift as it loads in",
                    "The compiler rejects lazy var in all structs",
                    "Network bandwidth doubles for each request",
                    "Lazy loaded data bypasses memory management"
                ],
                correctIndex: 0,
                explanation: "Late-arriving content can cause layout shifts and visual flicker, which is solved with placeholder skeletons and smooth transitions."),
        ],

        // MARK: CircuitBreaker (indices: 0, 2, 1)
        .circuitBreaker: [
            QuizQuestion(id: "gen_cb_1", blockType: .circuitBreaker,
                questionText: "What does a circuit breaker do after reaching its failure threshold?",
                options: [
                    "It stops sending requests to the service",
                    "It increases timeout for the next request",
                    "It routes traffic to a backup datacenter",
                    "It retries with exponential backoff delays"
                ],
                correctIndex: 0,
                explanation: "Once failures exceed the threshold, the circuit opens and immediately rejects new requests instead of wasting resources on a failing service."),
            QuizQuestion(id: "gen_cb_2", blockType: .circuitBreaker,
                questionText: "What is the purpose of the half-open state in a circuit breaker?",
                options: [
                    "It rejects exactly half of all new requests",
                    "It logs errors without blocking any request",
                    "It sends a test request to probe recovery",
                    "It switches between primary and backup APIs"
                ],
                correctIndex: 2,
                explanation: "The half-open state allows a single probe request through to check if the failing service has recovered before fully closing the circuit."),
            QuizQuestion(id: "gen_cb_3", blockType: .circuitBreaker,
                questionText: "Why is a circuit breaker better than unlimited retries for failures?",
                options: [
                    "Retries always succeed on the third attempt",
                    "It prevents cascading failures and overload",
                    "Retries consume less memory than a breaker",
                    "Circuit breakers guarantee zero data loss"
                ],
                correctIndex: 1,
                explanation: "Unlimited retries can overwhelm a struggling service, causing cascading failures. A circuit breaker gives the service time to recover."),
        ],

        // MARK: RetryHandler (indices: 3, 0, 2)
        .retryHandler: [
            QuizQuestion(id: "gen_rh_1", blockType: .retryHandler,
                questionText: "Why should retry delays increase exponentially rather than stay fixed?",
                options: [
                    "Fixed delays always exceed API rate limits",
                    "Exponential delays reduce code complexity",
                    "Fixed retries cause immediate recovery rate",
                    "Exponential backoff avoids thundering herd"
                ],
                correctIndex: 3,
                explanation: "Exponential backoff spaces out retries to avoid many clients retrying simultaneously and overwhelming the recovering service."),
            QuizQuestion(id: "gen_rh_2", blockType: .retryHandler,
                questionText: "Which HTTP errors should a retry handler skip retrying entirely?",
                options: [
                    "Client errors like 401 and 403 responses",
                    "Server errors like 500 and 503 responses",
                    "Timeout errors like 408 request timeouts",
                    "Network errors from connection resets only"
                ],
                correctIndex: 0,
                explanation: "Client errors (4xx) indicate bad requests that will never succeed regardless of retries. Only transient server/network errors are worth retrying."),
            QuizQuestion(id: "gen_rh_3", blockType: .retryHandler,
                questionText: "Why add jitter (randomness) to retry delay intervals?",
                options: [
                    "It makes retry logs easier to read clearly",
                    "Jitter reduces total bandwidth consumption",
                    "It prevents synchronized retry from clients",
                    "Random delays bypass server rate limiters"
                ],
                correctIndex: 2,
                explanation: "Jitter desynchronizes retries across clients so they don't all hit the server at the same moment after a shared failure window."),
        ],

        // MARK: Fallback (indices: 1, 3, 0)
        .fallback: [
            QuizQuestion(id: "gen_fb_1", blockType: .fallback,
                questionText: "What distinguishes a fallback from a simple error message to users?",
                options: [
                    "Fallbacks always show a blank empty screen",
                    "A fallback provides degraded but real value",
                    "Error messages trigger automatic retry logic",
                    "Fallbacks require an active internet status"
                ],
                correctIndex: 1,
                explanation: "Fallbacks provide reduced but functional experiences (cached data, defaults) instead of just telling the user something broke."),
            QuizQuestion(id: "gen_fb_2", blockType: .fallback,
                questionText: "When should a fallback strategy use cached data over static defaults?",
                options: [
                    "When the cache library supports Swift 6.0",
                    "When the app has not been opened in months",
                    "When the user should see no data at all now",
                    "When stale data is more useful than generic"
                ],
                correctIndex: 3,
                explanation: "Cached data reflects the user's actual content and is more relevant than generic defaults, even if slightly outdated."),
            QuizQuestion(id: "gen_fb_3", blockType: .fallback,
                questionText: "Why should a fallback log the original failure for later analysis?",
                options: [
                    "Logging helps diagnose root cause patterns",
                    "It allows the fallback to retry the request",
                    "Log files are required by the App Store now",
                    "Without logs the fallback data becomes stale"
                ],
                correctIndex: 0,
                explanation: "Silent fallbacks hide failures. Logging the root cause enables developers to identify and fix recurring issues."),
        ],

        // MARK: HealthMonitor (indices: 2, 1, 3)
        .healthMonitor: [
            QuizQuestion(id: "gen_hm_1", blockType: .healthMonitor,
                questionText: "What kind of metrics should a health monitor track for a mobile app?",
                options: [
                    "Only crash counts and nothing else needed",
                    "The number of Swift files in the project",
                    "Latency, error rates, and resource usage",
                    "User demographics and location data points"
                ],
                correctIndex: 2,
                explanation: "Comprehensive health monitoring tracks latency, error rates, memory usage, and battery impact to detect degradation before users notice."),
            QuizQuestion(id: "gen_hm_2", blockType: .healthMonitor,
                questionText: "Why should health checks run on a separate thread from the main UI?",
                options: [
                    "Health checks are not allowed on main thread",
                    "They could block UI rendering if they stall",
                    "Separate threads make results more accurate",
                    "The OS only allows network on main thread"
                ],
                correctIndex: 1,
                explanation: "Health checks that probe services or measure metrics can take time. Running them on the main thread would cause UI freezes and dropped frames."),
            QuizQuestion(id: "gen_hm_3", blockType: .healthMonitor,
                questionText: "When should a health monitor trigger an automatic degradation response?",
                options: [
                    "At every app launch regardless of the state",
                    "Only when the user manually reports issues",
                    "After receiving a push notification command",
                    "When error rate exceeds a defined threshold"
                ],
                correctIndex: 3,
                explanation: "Threshold-based triggers allow automatic responses like enabling fallbacks or disabling features when metrics indicate system degradation."),
        ],

        // MARK: MLModel (indices: 0, 3, 1)
        .mlModel: [
            QuizQuestion(id: "gen_ml_1", blockType: .mlModel,
                questionText: "Why should ML inference run off the main thread in a mobile app?",
                options: [
                    "Model inference can block UI for seconds",
                    "CoreML only supports background execution",
                    "ML models cannot access main thread memory",
                    "Background threads have higher GPU priority"
                ],
                correctIndex: 0,
                explanation: "ML inference can take hundreds of milliseconds, which would freeze the UI if run on the main thread and cause dropped frames."),
            QuizQuestion(id: "gen_ml_2", blockType: .mlModel,
                questionText: "What is the advantage of on-device ML over server-side inference?",
                options: [
                    "On-device models are always more accurate",
                    "Server models require no internet to call",
                    "On-device eliminates backend infra costs",
                    "Results come without network round trip"
                ],
                correctIndex: 3,
                explanation: "On-device inference eliminates network latency and works offline, providing instant results regardless of connectivity."),
            QuizQuestion(id: "gen_ml_3", blockType: .mlModel,
                questionText: "Why should an ML component expose a protocol instead of CoreML types?",
                options: [
                    "CoreML types are deprecated in iOS seventeen",
                    "Protocols enable mock models for unit tests",
                    "Concrete types prevent compile-time checking",
                    "Protocols automatically optimize model speed"
                ],
                correctIndex: 1,
                explanation: "A protocol boundary lets you substitute mock predictions in tests and swap model versions without changing consumer code."),
        ],

        // MARK: WebSocket (indices: 3, 2, 0)
        .websocket: [
            QuizQuestion(id: "gen_ws_1", blockType: .websocket,
                questionText: "What advantage do WebSockets have over repeated HTTP polling?",
                options: [
                    "HTTP polling uses encrypted connections",
                    "WebSockets require simpler server setup",
                    "Polling delivers data with lower latency",
                    "WebSockets push updates without polling"
                ],
                correctIndex: 3,
                explanation: "WebSockets maintain an open bidirectional connection, allowing the server to push updates instantly without the client repeatedly asking."),
            QuizQuestion(id: "gen_ws_2", blockType: .websocket,
                questionText: "Why must a WebSocket client implement reconnection logic?",
                options: [
                    "The protocol spec mandates auto-reconnect",
                    "Servers close idle sockets after a timeout",
                    "Connections drop due to network instability",
                    "Reconnection prevents duplicate messages"
                ],
                correctIndex: 2,
                explanation: "Mobile networks are inherently unstable. WebSocket connections can drop from cell tower handoffs, WiFi switches, or signal loss."),
            QuizQuestion(id: "gen_ws_3", blockType: .websocket,
                questionText: "How should a WebSocket handler manage messages during reconnection?",
                options: [
                    "Buffer incoming messages in a local queue",
                    "Discard all messages until fully connected",
                    "Notify the server to pause message sending",
                    "Switch to HTTP polling until reconnected"
                ],
                correctIndex: 0,
                explanation: "Buffering messages during reconnection ensures no data is lost and messages can be processed in order once the connection is restored."),
        ],

        // MARK: EventBus (indices: 1, 0, 2)
        .eventBus: [
            QuizQuestion(id: "gen_eb_1", blockType: .eventBus,
                questionText: "What problem does an event bus solve between decoupled components?",
                options: [
                    "It makes all components share a single file",
                    "It lets components communicate without refs",
                    "It guarantees events arrive in under one ms",
                    "It replaces the need for protocol conformance"
                ],
                correctIndex: 1,
                explanation: "An event bus enables publish-subscribe communication where components interact without holding direct references to each other."),
            QuizQuestion(id: "gen_eb_2", blockType: .eventBus,
                questionText: "What is the main risk of overusing an event bus in an architecture?",
                options: [
                    "Event flow becomes hard to trace and debug",
                    "The bus runs out of capacity for new events",
                    "Event ordering is guaranteed to be reversed",
                    "Subscribers cannot receive events on time"
                ],
                correctIndex: 0,
                explanation: "Excessive event bus usage creates invisible dependencies that are hard to trace, debug, and reason about compared to explicit method calls."),
            QuizQuestion(id: "gen_eb_3", blockType: .eventBus,
                questionText: "Why must event bus subscribers unsubscribe when their view is dismissed?",
                options: [
                    "The event bus has a maximum subscriber limit",
                    "Subscriptions block new views from loading",
                    "Stale listeners cause leaks and ghost updates",
                    "The OS reclaims bus memory upon dismissal"
                ],
                correctIndex: 2,
                explanation: "Retained subscriptions from dismissed views cause memory leaks and unexpected side effects when events trigger on deallocated objects."),
        ],

        // MARK: StateMachine (indices: 2, 3, 1)
        .stateMachine: [
            QuizQuestion(id: "gen_sm_1", blockType: .stateMachine,
                questionText: "Why use a state machine instead of scattered boolean flags?",
                options: [
                    "Booleans use more memory than enum cases",
                    "State machines execute code more quickly",
                    "It makes impossible states unrepresentable",
                    "Boolean flags cannot be used in switch cases"
                ],
                correctIndex: 2,
                explanation: "A state machine with an enum ensures only valid states exist, eliminating bugs from contradictory flag combinations like isLoading AND hasError."),
            QuizQuestion(id: "gen_sm_2", blockType: .stateMachine,
                questionText: "What does a state machine's transition table enforce?",
                options: [
                    "It limits how much memory each state uses",
                    "It ensures states render correct UI layouts",
                    "It controls the speed of state transitions",
                    "It defines which state changes are allowed"
                ],
                correctIndex: 3,
                explanation: "A transition table explicitly lists valid state transitions, preventing invalid jumps like going from 'error' directly to 'success' without retrying."),
            QuizQuestion(id: "gen_sm_3", blockType: .stateMachine,
                questionText: "When is a state machine overkill for a simple feature?",
                options: [
                    "When the feature is used by many users now",
                    "When there are only two mutually exclusive states",
                    "When the feature requires network connectivity",
                    "When the state needs to persist across launch"
                ],
                correctIndex: 1,
                explanation: "For simple binary states (on/off, visible/hidden), a single boolean is clearer and more maintainable than a full state machine."),
        ],
    ]

    // MARK: - Specific Questions (per problem + block type)

    // correctIndex distribution across 69 specific questions:
    // 0: 17, 1: 17, 2: 18, 3: 17

    private static let specificQuestions: [String: [QuizQuestion]] = [

        // MARK: T1 Notes - ViewModel (indices: 0, 2, 3)
        "t1_notes_viewModel": [
            QuizQuestion(id: "t1n_vm_1", blockType: .viewModel,
                questionText: "In a Notes app, why should the ViewModel sort notes instead of the View?",
                options: [
                    "Sorting logic can be tested without any UI",
                    "SwiftUI lists cannot accept sorted arrays",
                    "Views automatically sort by creation date",
                    "The database always returns pre-sorted data"
                ],
                correctIndex: 0,
                explanation: "Moving sort logic to the ViewModel makes it independently testable and keeps the View focused purely on layout and rendering."),
            QuizQuestion(id: "t1n_vm_2", blockType: .viewModel,
                questionText: "How should the Notes ViewModel handle a failed save operation?",
                options: [
                    "Silently discard the note to avoid crashes",
                    "Retry the save in an infinite loop until ok",
                    "Update an error state property for the View",
                    "Force quit the app to prevent data corruption"
                ],
                correctIndex: 2,
                explanation: "The ViewModel should set an error state that the View observes, allowing it to show an appropriate error message to the user."),
            QuizQuestion(id: "t1n_vm_3", blockType: .viewModel,
                questionText: "Why should the Notes ViewModel debounce auto-save during text editing?",
                options: [
                    "SwiftUI text fields only update once per sec",
                    "Users prefer manual save buttons over auto",
                    "The database rejects writes faster than 1 Hz",
                    "Saving every keystroke wastes resources badly"
                ],
                correctIndex: 3,
                explanation: "Debouncing batches rapid keystrokes into fewer save operations, reducing disk I/O and CPU usage during active typing."),
        ],

        // MARK: T1 Notes - Repository (indices: 1, 3, 0)
        "t1_notes_repository": [
            QuizQuestion(id: "t1n_repo_1", blockType: .repository,
                questionText: "Why should the Notes Repository abstract SwiftData from the ViewModel?",
                options: [
                    "SwiftData cannot store plain text content",
                    "It lets you swap persistence without changes",
                    "ViewModels crash when touching SwiftData now",
                    "SwiftData queries must run on a background"
                ],
                correctIndex: 1,
                explanation: "Abstracting persistence means you could swap SwiftData for Core Data or a file-based system without modifying ViewModel code."),
            QuizQuestion(id: "t1n_repo_2", blockType: .repository,
                questionText: "How should the Notes Repository handle concurrent edits to one note?",
                options: [
                    "Allow both writes and merge text at the end",
                    "Lock the entire database until the edit ends",
                    "Reject the second edit with a generic error",
                    "Use last-write-wins with conflict notification"
                ],
                correctIndex: 3,
                explanation: "Last-write-wins is simple and effective for single-user apps, with optional conflict notification so the user knows data was overwritten."),
            QuizQuestion(id: "t1n_repo_3", blockType: .repository,
                questionText: "What should the Notes Repository return when the database is empty?",
                options: [
                    "An empty array to signal no notes exist yet",
                    "Nil to indicate the database is uninitialized",
                    "A single placeholder note with sample content",
                    "An error saying no data has been created now"
                ],
                correctIndex: 0,
                explanation: "An empty array is a valid result that the ViewModel can use to show an empty state, without conflating 'no data' with 'error'."),
        ],

        // MARK: T1 Habit - ViewModel (indices: 2, 0, 1)
        "t1_habit_viewModel": [
            QuizQuestion(id: "t1h_vm_1", blockType: .viewModel,
                questionText: "How should the Habit Tracker ViewModel calculate a streak count?",
                options: [
                    "Count total completions regardless of dates",
                    "Query the database for the streak each time",
                    "Walk backwards from today counting each day",
                    "Store the streak as a static constant value"
                ],
                correctIndex: 2,
                explanation: "Walking backwards from today through consecutive completion dates gives the current streak, resetting when a gap day is found."),
            QuizQuestion(id: "t1h_vm_2", blockType: .viewModel,
                questionText: "Why should the Habit ViewModel own the completion toggle logic?",
                options: [
                    "It validates before persisting the change",
                    "Views cannot send actions to the repository",
                    "Toggle logic requires network connectivity",
                    "SwiftUI buttons do not support tap handlers"
                ],
                correctIndex: 0,
                explanation: "The ViewModel can validate (prevent double-completion, check date) before persisting, rather than blindly toggling state."),
            QuizQuestion(id: "t1h_vm_3", blockType: .viewModel,
                questionText: "What should the Habit ViewModel expose for the weekly chart view?",
                options: [
                    "Raw database records with all field values",
                    "Pre-computed daily completion percentages",
                    "The SwiftData model context for direct query",
                    "A network URL pointing to a chart image file"
                ],
                correctIndex: 1,
                explanation: "The ViewModel should pre-compute display-ready data so the chart View simply renders values without performing calculations."),
        ],

        // MARK: T1 Habit - BackgroundWorker (indices: 3, 1, 2)
        "t1_habit_backgroundWorker": [
            QuizQuestion(id: "t1h_bw_1", blockType: .backgroundWorker,
                questionText: "Why does the Habit Tracker need a background worker for notifications?",
                options: [
                    "Notifications cannot be scheduled from Views",
                    "Background workers have elevated permissions",
                    "Scheduling uses less battery from background",
                    "Main thread scheduling blocks the UI heavily"
                ],
                correctIndex: 3,
                explanation: "Scheduling multiple notifications involves date calculations and system API calls that would cause noticeable UI freezes on the main thread."),
            QuizQuestion(id: "t1h_bw_2", blockType: .backgroundWorker,
                questionText: "How should the habit background worker handle a midnight reset?",
                options: [
                    "Force quit the app and restart at midnight",
                    "Reset daily flags via a scheduled background task",
                    "Require the user to manually reset each habit",
                    "Ignore midnight and reset on next app launch"
                ],
                correctIndex: 1,
                explanation: "A scheduled background task ensures daily flags reset at midnight even if the app is not actively running, keeping data accurate."),
            QuizQuestion(id: "t1h_bw_3", blockType: .backgroundWorker,
                questionText: "What should the habit worker do if background execution time expires?",
                options: [
                    "Continue running and ignore the time limit",
                    "Delete incomplete work to stay consistent now",
                    "Save partial progress and resume on next run",
                    "Crash intentionally so the OS restarts the app"
                ],
                correctIndex: 2,
                explanation: "Saving progress checkpoints allows the worker to resume where it left off on the next execution opportunity instead of losing work."),
        ],

        // MARK: T1 Todo - ViewModel (indices: 0, 3, 1)
        "t1_todo_viewModel": [
            QuizQuestion(id: "t1t_vm_1", blockType: .viewModel,
                questionText: "Why should the Todo ViewModel filter tasks instead of using multiple arrays?",
                options: [
                    "A single source of truth prevents sync bugs",
                    "Multiple arrays use significantly less memory",
                    "SwiftUI cannot observe more than one array",
                    "Filtered views perform worse than raw arrays"
                ],
                correctIndex: 0,
                explanation: "Maintaining one task array and computing filtered views prevents inconsistencies that arise from keeping multiple lists in sync."),
            QuizQuestion(id: "t1t_vm_2", blockType: .viewModel,
                questionText: "How should the Todo ViewModel handle reordering tasks by priority?",
                options: [
                    "Let the database sort via a query predicate",
                    "Store display order as a property on each task",
                    "Sort alphabetically as a universal fallback",
                    "Recompute sort order in the ViewModel's state"
                ],
                correctIndex: 3,
                explanation: "The ViewModel should own sort logic so different screens can show different orderings from the same data without modifying persistence."),
            QuizQuestion(id: "t1t_vm_3", blockType: .viewModel,
                questionText: "What state should the Todo ViewModel track during a batch delete?",
                options: [
                    "Only the count of items that were deleted",
                    "An in-progress flag and potential error state",
                    "The exact timestamp when deletion was started",
                    "Nothing because deletes are always instant"
                ],
                correctIndex: 1,
                explanation: "Tracking in-progress state lets the View show a loading indicator, and error state enables showing a failure message if the delete fails."),
        ],

        // MARK: T2 Weather - ViewModel (indices: 2, 0, 3)
        "t2_weather_viewModel": [
            QuizQuestion(id: "t2w_vm_1", blockType: .viewModel,
                questionText: "Why should the Weather ViewModel convert Kelvin to user-preferred units?",
                options: [
                    "The View should handle unit conversion itself",
                    "APIs always return in the user locale already",
                    "Unit conversion is a display concern for the VM",
                    "Kelvin is the only unit SwiftUI can render"
                ],
                correctIndex: 2,
                explanation: "Temperature conversion is presentation logic that belongs in the ViewModel, keeping the View free of formatting calculations."),
            QuizQuestion(id: "t2w_vm_2", blockType: .viewModel,
                questionText: "How should the Weather ViewModel handle location permission denial?",
                options: [
                    "Show a state explaining how to grant access",
                    "Continuously prompt until permission granted",
                    "Crash the app since location is now required",
                    "Silently default to coordinates of zero, zero"
                ],
                correctIndex: 0,
                explanation: "The ViewModel should expose an appropriate state so the View can guide the user to Settings to grant location access."),
            QuizQuestion(id: "t2w_vm_3", blockType: .viewModel,
                questionText: "What approach should the Weather ViewModel take for pull-to-refresh?",
                options: [
                    "Ignore refresh if last fetch was under an hour",
                    "Clear all cached data before starting the fetch",
                    "Show stale data with a badge indicating its age",
                    "Bypass cache and request fresh API data always"
                ],
                correctIndex: 3,
                explanation: "Pull-to-refresh is an explicit user intent to get fresh data, so the ViewModel should bypass any cache and fetch from the API directly."),
        ],

        // MARK: T2 Weather - Repository (indices: 1, 3, 2)
        "t2_weather_repository": [
            QuizQuestion(id: "t2w_repo_1", blockType: .repository,
                questionText: "Why should the Weather Repository cache responses with a short TTL?",
                options: [
                    "Weather APIs charge per request after limits",
                    "Short TTL balances freshness against API cost",
                    "Long TTL ensures data is always up to date now",
                    "Caching is unnecessary for weather data at all"
                ],
                correctIndex: 1,
                explanation: "Weather changes frequently, so a short TTL (like 10-30 minutes) reduces unnecessary API calls while keeping data reasonably fresh."),
            QuizQuestion(id: "t2w_repo_2", blockType: .repository,
                questionText: "What should the Weather Repository return when both API and cache fail?",
                options: [
                    "Fabricated weather data based on the season",
                    "An empty response with no indication of error",
                    "A random city's weather as a best-effort guess",
                    "A typed error the ViewModel can present to users"
                ],
                correctIndex: 3,
                explanation: "A typed error allows the ViewModel to decide how to present the failure-showing an error view, suggesting retry, or falling back gracefully."),
            QuizQuestion(id: "t2w_repo_3", blockType: .repository,
                questionText: "How should the Weather Repository handle rapid duplicate location requests?",
                options: [
                    "Send each request independently every time now",
                    "Queue requests and respond with a day-old cache",
                    "Coalesce duplicate calls into a single request",
                    "Reject all duplicate requests with a rate error"
                ],
                correctIndex: 2,
                explanation: "Request coalescing deduplicates identical in-flight requests so only one network call is made, sharing the result with all callers."),
        ],

        // MARK: T2 News - NetworkCache (indices: 0, 2, 1)
        "t2_news_networkCache": [
            QuizQuestion(id: "t2n_nc_1", blockType: .networkCache,
                questionText: "Why should the News app cache articles with their full content included?",
                options: [
                    "Users expect to read articles while offline",
                    "Cached articles load slower than fresh fetches",
                    "News APIs do not support partial responses yet",
                    "Full content uses less storage than summaries"
                ],
                correctIndex: 0,
                explanation: "Caching full article content enables offline reading, which is a key user expectation for news apps during commutes or flights."),
            QuizQuestion(id: "t2n_nc_2", blockType: .networkCache,
                questionText: "How should the News cache handle articles that have been updated upstream?",
                options: [
                    "Never update once an article is cached locally",
                    "Delete the entire cache and re-fetch everything",
                    "Compare ETags and refresh only changed articles",
                    "Ask the user to decide for each stale article"
                ],
                correctIndex: 2,
                explanation: "ETag comparison allows efficient conditional requests that only download changed articles, saving bandwidth and time."),
            QuizQuestion(id: "t2n_nc_3", blockType: .networkCache,
                questionText: "What eviction strategy best fits a News app's cache of articles?",
                options: [
                    "First-in-first-out regardless of popularity",
                    "Remove oldest unread articles beyond a limit",
                    "Never evict and let storage grow unbounded",
                    "Random eviction to simplify the code's logic"
                ],
                correctIndex: 1,
                explanation: "Evicting oldest unread articles keeps the cache relevant by preserving recently viewed and bookmarked content while managing storage."),
        ],

        // MARK: T2 GitHub - Repository (indices: 3, 1, 0)
        "t2_github_repository": [
            QuizQuestion(id: "t2g_repo_1", blockType: .repository,
                questionText: "Why should the GitHub Repository paginate API results instead of fetching all?",
                options: [
                    "The GitHub API does not support full fetches",
                    "Pagination increases the total download size",
                    "All results always fit in a single API response",
                    "Large result sets waste bandwidth and memory"
                ],
                correctIndex: 3,
                explanation: "Fetching all results at once for large repos wastes bandwidth and memory. Pagination loads data incrementally as the user scrolls."),
            QuizQuestion(id: "t2g_repo_2", blockType: .repository,
                questionText: "How should the GitHub Repository handle API rate limit responses?",
                options: [
                    "Immediately switch to an unauthenticated call",
                    "Surface the rate limit reset time to the user",
                    "Retry the same request without any delay added",
                    "Ignore the error and return an empty result set"
                ],
                correctIndex: 1,
                explanation: "Showing the user when their rate limit resets gives them actionable information instead of confusing them with empty or stale data."),
            QuizQuestion(id: "t2g_repo_3", blockType: .repository,
                questionText: "Why should the GitHub Repository normalize API responses into domain models?",
                options: [
                    "It decouples the app from API schema changes",
                    "Domain models are required by the Swift compiler",
                    "JSON types are incompatible with SwiftUI views",
                    "Normalization doubles the speed of JSON parsing"
                ],
                correctIndex: 0,
                explanation: "Mapping API responses to domain models means changes to the GitHub API structure only require updating the repository's mapping layer."),
        ],

        // MARK: T3 Photo - ImageCache (indices: 2, 0, 3)
        "t3_photo_imageCache": [
            QuizQuestion(id: "t3p_ic_1", blockType: .imageCache,
                questionText: "Why should the Photo app cache thumbnails separately from full images?",
                options: [
                    "Thumbnails and full images use the same size",
                    "The OS prevents caching images at two sizes",
                    "Thumbnails are accessed far more frequently",
                    "Full images are never needed after thumbnailing"
                ],
                correctIndex: 2,
                explanation: "Thumbnails are displayed in grids and lists far more often than full images. Separate caching optimizes memory for the common case."),
            QuizQuestion(id: "t3p_ic_2", blockType: .imageCache,
                questionText: "What should the Photo image cache do when a memory warning fires?",
                options: [
                    "Evict decoded bitmaps and keep only file refs",
                    "Increase cache size to prevent future warnings",
                    "Ignore the warning since the OS handles memory",
                    "Delete all photos from the database permanently"
                ],
                correctIndex: 0,
                explanation: "Evicting decoded bitmaps frees significant memory while keeping file references allows re-decoding on demand when memory stabilizes."),
            QuizQuestion(id: "t3p_ic_3", blockType: .imageCache,
                questionText: "Why should the Photo image cache use image dimensions as part of the key?",
                options: [
                    "Dimensions make the hash function run faster",
                    "All images in the app share the same pixel size",
                    "Keys with dimensions are shorter in byte length",
                    "Same image at different sizes needs unique entries"
                ],
                correctIndex: 3,
                explanation: "A photo may be cached as a thumbnail and a full-size image. Including dimensions in the key prevents overwriting one with the other."),
        ],

        // MARK: T3 Photo - BackgroundWorker (indices: 1, 3, 0)
        "t3_photo_backgroundWorker": [
            QuizQuestion(id: "t3p_bw_1", blockType: .backgroundWorker,
                questionText: "Why should photo uploads happen in a background worker, not inline?",
                options: [
                    "Upload APIs only accept background sessions",
                    "Users can continue browsing during the upload",
                    "Inline uploads are faster than background ones",
                    "Photos must be compressed before upload begins"
                ],
                correctIndex: 1,
                explanation: "Background uploads let the user continue interacting with the app instead of staring at a progress spinner blocking the UI."),
            QuizQuestion(id: "t3p_bw_2", blockType: .backgroundWorker,
                questionText: "How should the Photo worker handle upload failure for a batch of images?",
                options: [
                    "Cancel remaining images and delete them all",
                    "Skip the failed image and continue silently",
                    "Restart the entire batch from the first image",
                    "Mark the failed image for retry and continue"
                ],
                correctIndex: 3,
                explanation: "Marking failures for retry while continuing successful uploads maximizes throughput and gives the user complete results eventually."),
            QuizQuestion(id: "t3p_bw_3", blockType: .backgroundWorker,
                questionText: "What should the Photo worker report to the ViewModel during processing?",
                options: [
                    "Incremental progress for each photo in batch",
                    "Only a final success or failure for the batch",
                    "The internal thread ID handling the operation",
                    "Nothing until all processing is fully complete"
                ],
                correctIndex: 0,
                explanation: "Incremental progress allows the UI to show per-photo progress indicators, giving users clear feedback on long-running operations."),
        ],

        // MARK: T3 Restaurant - MemoryCache (indices: 2, 1, 3)
        "t3_restaurant_memoryCache": [
            QuizQuestion(id: "t3r_mc_1", blockType: .memoryCache,
                questionText: "Why should the Restaurant app cache menu data in memory rather than disk?",
                options: [
                    "Menu data changes too often for disk caching",
                    "Disk caches cannot store structured JSON data",
                    "Menus are small and benefit from instant access",
                    "Memory cache persists better across app launches"
                ],
                correctIndex: 2,
                explanation: "Menu data is typically small and frequently accessed during browsing. Memory cache provides instant reads without disk I/O overhead."),
            QuizQuestion(id: "t3r_mc_2", blockType: .memoryCache,
                questionText: "How should the Restaurant memory cache handle multiple location switches?",
                options: [
                    "Keep all locations cached until memory warning",
                    "Clear previous location cache on each switch",
                    "Cache only the first location user ever views",
                    "Store locations on disk instead of in memory"
                ],
                correctIndex: 1,
                explanation: "Clearing the previous location's cache frees memory and prevents showing stale menu data from a different restaurant."),
            QuizQuestion(id: "t3r_mc_3", blockType: .memoryCache,
                questionText: "What should the Restaurant cache do when a menu item image is unavailable?",
                options: [
                    "Leave the cache entry empty for that item now",
                    "Remove the entire restaurant from the cache",
                    "Fetch from disk cache and fall back to network",
                    "Cache a placeholder to prevent repeated fetches"
                ],
                correctIndex: 3,
                explanation: "Caching a placeholder image prevents repeated network requests for a missing image and provides a consistent visual fallback."),
        ],

        // MARK: T3 Podcast - BackgroundWorker (indices: 0, 2, 1)
        "t3_podcast_backgroundWorker": [
            QuizQuestion(id: "t3pc_bw_1", blockType: .backgroundWorker,
                questionText: "Why should podcast episode downloads use a background URL session?",
                options: [
                    "Downloads continue even when the app suspends",
                    "Background sessions have higher bandwidth caps",
                    "Foreground sessions cannot download audio files",
                    "The OS prioritizes background network traffic"
                ],
                correctIndex: 0,
                explanation: "Background URL sessions let the system continue downloads after the user leaves the app, completing large audio files reliably."),
            QuizQuestion(id: "t3pc_bw_2", blockType: .backgroundWorker,
                questionText: "How should the Podcast worker prioritize downloads in a queue?",
                options: [
                    "Alphabetically by episode title for simplicity",
                    "Randomly to distribute server load more evenly",
                    "Next-to-play episodes before older queue items",
                    "Smallest files first to show quick completions"
                ],
                correctIndex: 2,
                explanation: "Prioritizing next-to-play episodes ensures the content the user wants soonest is ready first, optimizing their listening experience."),
            QuizQuestion(id: "t3pc_bw_3", blockType: .backgroundWorker,
                questionText: "What should the Podcast worker do when disk space runs low mid-download?",
                options: [
                    "Delete previously downloaded episodes silently",
                    "Pause the download and alert the user to act",
                    "Compress the partial file to save disk space",
                    "Continue downloading and let the OS manage it"
                ],
                correctIndex: 1,
                explanation: "Pausing and alerting the user lets them decide what to remove, rather than the app making destructive decisions about their content."),
        ],

        // MARK: T4 Banking - CircuitBreaker (indices: 3, 0, 2)
        "t4_banking_circuitBreaker": [
            QuizQuestion(id: "t4b_cb_1", blockType: .circuitBreaker,
                questionText: "Why is a circuit breaker critical for a banking app's transaction service?",
                options: [
                    "It makes transaction processing twice as fast",
                    "Banks require circuit breakers for compliance",
                    "It encrypts financial data during transmission",
                    "It prevents repeated calls to a failing server"
                ],
                correctIndex: 3,
                explanation: "Repeated calls to a failing payment server could cause duplicate charges or timeouts. A circuit breaker stops calls and shows a clean error."),
            QuizQuestion(id: "t4b_cb_2", blockType: .circuitBreaker,
                questionText: "What should the banking circuit breaker do in the open state?",
                options: [
                    "Return a cached successful transaction result",
                    "Immediately fail with a user-friendly message",
                    "Redirect transactions to a secondary endpoint",
                    "Queue transactions for later batch processing"
                ],
                correctIndex: 0,
                explanation: "In open state, returning a cached balance or last-known state provides the user with useful information while the service recovers."),
            QuizQuestion(id: "t4b_cb_3", blockType: .circuitBreaker,
                questionText: "How should the banking app's circuit breaker threshold differ from a news app?",
                options: [
                    "Banking should use the same threshold value now",
                    "News apps should have a much lower threshold",
                    "Banking needs a lower threshold for safety",
                    "Threshold differences have no real-world impact"
                ],
                correctIndex: 2,
                explanation: "Financial transactions are high-stakes. A lower failure threshold opens the circuit sooner, protecting users from duplicate charges."),
        ],

        // MARK: T4 Banking - RetryHandler (indices: 1, 3, 0)
        "t4_banking_retryHandler": [
            QuizQuestion(id: "t4b_rh_1", blockType: .retryHandler,
                questionText: "Why should the banking retry handler use idempotency keys per transaction?",
                options: [
                    "Keys make the retry code simpler to maintain",
                    "It ensures retried requests create one charge",
                    "Idempotency keys speed up the server response",
                    "Without keys, retries return cached responses"
                ],
                correctIndex: 1,
                explanation: "Idempotency keys let the server recognize a retried request and return the original result instead of processing a duplicate charge."),
            QuizQuestion(id: "t4b_rh_2", blockType: .retryHandler,
                questionText: "When should the banking retry handler give up and stop retrying entirely?",
                options: [
                    "After a single failed attempt to stay safe now",
                    "Only after the user manually cancels the action",
                    "Never, since financial data must always go thru",
                    "After a defined max retries with clear feedback"
                ],
                correctIndex: 3,
                explanation: "A bounded retry count with user feedback prevents infinite loops while giving the user actionable next steps after exhausting retries."),
            QuizQuestion(id: "t4b_rh_3", blockType: .retryHandler,
                questionText: "Why must banking retries avoid retrying 4xx client error responses?",
                options: [
                    "Retrying bad requests wastes time and data",
                    "Client errors always resolve after one retry",
                    "The server ignores retried client error codes",
                    "Client errors indicate temporary server issues"
                ],
                correctIndex: 0,
                explanation: "Client errors like 400 (bad request) or 403 (forbidden) indicate problems with the request itself that no amount of retrying will fix."),
        ],

        // MARK: T4 Rideshare - HealthMonitor (indices: 2, 0, 3)
        "t4_rideshare_healthMonitor": [
            QuizQuestion(id: "t4r_hm_1", blockType: .healthMonitor,
                questionText: "Why does a rideshare app need to monitor GPS accuracy as a health metric?",
                options: [
                    "GPS accuracy affects battery life only, not UX",
                    "The OS handles all location accuracy internally",
                    "Inaccurate GPS causes wrong pickup locations",
                    "Health monitors cannot track hardware sensors"
                ],
                correctIndex: 2,
                explanation: "Poor GPS accuracy in urban areas leads to incorrect pickup locations, directly impacting the core user experience of hailing a ride."),
            QuizQuestion(id: "t4r_hm_2", blockType: .healthMonitor,
                questionText: "What should the rideshare health monitor do when WebSocket latency spikes?",
                options: [
                    "Increase the polling interval for driver location",
                    "Switch to HTTP polling as a fallback strategy",
                    "Notify the user that tracking is temporarily off",
                    "Reduce map rendering quality to save resources"
                ],
                correctIndex: 0,
                explanation: "Increasing the polling interval when latency is high reduces load on a strained connection while maintaining functional driver tracking."),
            QuizQuestion(id: "t4r_hm_3", blockType: .healthMonitor,
                questionText: "How should the rideshare health monitor handle consistent payment failures?",
                options: [
                    "Automatically switch to the next payment method",
                    "Disable ride requests and show service status",
                    "Continue allowing rides and charge users later",
                    "Alert the payment service and disable the circuit"
                ],
                correctIndex: 3,
                explanation: "Consistent payment failures indicate a systemic issue. The health monitor should trigger the circuit breaker and alert the payment service."),
        ],

        // MARK: T4 Ecommerce - Fallback (indices: 1, 2, 0)
        "t4_ecommerce_fallback": [
            QuizQuestion(id: "t4e_fb_1", blockType: .fallback,
                questionText: "What should the ecommerce fallback show when product search fails?",
                options: [
                    "An empty screen with no explanation at all now",
                    "Recently viewed products as a useful alternative",
                    "A generic error code from the server's response",
                    "A suggestion to uninstall and reinstall the app"
                ],
                correctIndex: 1,
                explanation: "Showing recently viewed products provides a useful browsing experience even when search is unavailable, keeping users engaged."),
            QuizQuestion(id: "t4e_fb_2", blockType: .fallback,
                questionText: "Why should the ecommerce cart fallback to locally cached prices?",
                options: [
                    "Cached prices are always more accurate than live",
                    "Users cannot compare prices without live access",
                    "It lets users review their cart while offline",
                    "Local prices load faster than the server prices"
                ],
                correctIndex: 2,
                explanation: "Showing cached prices lets users review their cart contents offline, with a note that final prices will be confirmed at checkout."),
            QuizQuestion(id: "t4e_fb_3", blockType: .fallback,
                questionText: "How should the ecommerce fallback handle an unavailable checkout service?",
                options: [
                    "Save the cart and offer to notify when it's back",
                    "Process the order locally and sync it later now",
                    "Redirect users to the mobile website for payment",
                    "Show a countdown timer for estimated recovery"
                ],
                correctIndex: 0,
                explanation: "Saving the cart and offering notification respects the user's intent while being honest that checkout is temporarily unavailable."),
        ],

        // MARK: T5 Photos - MLModel (indices: 3, 1, 2)
        "t5_photos_mlModel": [
            QuizQuestion(id: "t5p_ml_1", blockType: .mlModel,
                questionText: "Why should the Photos ML model process images in batches rather than one by one?",
                options: [
                    "Single image processing is more accurate overall",
                    "CoreML only accepts arrays of image inputs now",
                    "Batching prevents the model from overheating",
                    "Batch processing amortizes model loading costs"
                ],
                correctIndex: 3,
                explanation: "Loading the ML model into memory is expensive. Batching amortizes this cost across many images instead of paying it per photo."),
            QuizQuestion(id: "t5p_ml_2", blockType: .mlModel,
                questionText: "How should the Photos ML model handle an image it cannot classify?",
                options: [
                    "Assign a random category to avoid empty results",
                    "Return a low-confidence result with a fallback",
                    "Delete the image from the user's photo library",
                    "Crash to signal the model needs to be retrained"
                ],
                correctIndex: 1,
                explanation: "Returning a low-confidence result lets the app decide whether to show the uncertain classification or fall back to 'uncategorized'."),
            QuizQuestion(id: "t5p_ml_3", blockType: .mlModel,
                questionText: "Why should ML classification results be cached alongside photo metadata?",
                options: [
                    "ML models cannot classify the same image twice",
                    "Metadata storage is free and has no size impact",
                    "It avoids costly re-inference on already-seen photos",
                    "The Photos framework requires cached ML results"
                ],
                correctIndex: 2,
                explanation: "ML inference is computationally expensive. Caching results with metadata prevents re-running classification every time a photo is viewed."),
        ],

        // MARK: T5 Photos - StateMachine (indices: 0, 3, 1)
        "t5_photos_stateMachine": [
            QuizQuestion(id: "t5p_sm_1", blockType: .stateMachine,
                questionText: "Why does photo editing benefit from a state machine over boolean flags?",
                options: [
                    "It prevents being in edit and export at once",
                    "Boolean flags are faster for UI state updates",
                    "State machines require less code than booleans",
                    "Photo editors only have two possible app states"
                ],
                correctIndex: 0,
                explanation: "A state machine ensures mutually exclusive states. You cannot accidentally be editing and exporting simultaneously, which booleans could allow."),
            QuizQuestion(id: "t5p_sm_2", blockType: .stateMachine,
                questionText: "What should the Photos state machine do when an export fails mid-process?",
                options: [
                    "Return to the browsing state and discard edits",
                    "Stay in the export state and show a retry option",
                    "Transition to editing state to let user continue",
                    "Transition to error state with recovery options"
                ],
                correctIndex: 3,
                explanation: "An explicit error state preserves the user's context and presents clear recovery options like retry or save-as-draft."),
            QuizQuestion(id: "t5p_sm_3", blockType: .stateMachine,
                questionText: "Why should the Photos state machine log all state transitions?",
                options: [
                    "Logs are required by Apple for App Store review",
                    "Transition logs help debug unexpected user flows",
                    "Without logs the state machine stops functioning",
                    "Logging forces transitions to execute more slowly"
                ],
                correctIndex: 1,
                explanation: "Transition logs create an audit trail that makes it easy to reproduce and debug unexpected navigation paths or state corruption."),
        ],

        // MARK: T5 Sports - WebSocket (indices: 2, 0, 3)
        "t5_sports_websocket": [
            QuizQuestion(id: "t5s_ws_1", blockType: .websocket,
                questionText: "Why is WebSocket ideal for live sports scores instead of REST polling?",
                options: [
                    "REST APIs do not support sports data formats",
                    "Polling intervals match real-time game events",
                    "Server pushes score changes the instant they happen",
                    "WebSockets use less battery than a single REST call"
                ],
                correctIndex: 2,
                explanation: "WebSockets deliver score updates the moment they occur on the server, while polling would miss events between intervals."),
            QuizQuestion(id: "t5s_ws_2", blockType: .websocket,
                questionText: "How should the Sports app handle a WebSocket disconnect during a live game?",
                options: [
                    "Reconnect with backoff and fetch missed scores",
                    "Show a static page until the user restarts app",
                    "Switch to a different sport that has connection",
                    "Assume the game ended and show the final score"
                ],
                correctIndex: 0,
                explanation: "Automatic reconnection with backoff restores the live feed, and fetching missed scores via REST ensures no updates are lost during the gap."),
            QuizQuestion(id: "t5s_ws_3", blockType: .websocket,
                questionText: "Why should the Sports WebSocket deduplicate incoming score updates?",
                options: [
                    "Duplicate scores cause the app to crash always",
                    "The server never sends duplicate messages at all",
                    "Deduplication saves server-side bandwidth costs",
                    "Reconnection can replay events already received"
                ],
                correctIndex: 3,
                explanation: "After reconnection, the server may resend recent events. Deduplication using event IDs prevents showing the same score update twice."),
        ],

        // MARK: T5 Sports - EventBus (indices: 1, 3, 0)
        "t5_sports_eventBus": [
            QuizQuestion(id: "t5s_eb_1", blockType: .eventBus,
                questionText: "Why should the Sports app use an event bus for score update distribution?",
                options: [
                    "Event buses encrypt data for secure transmission",
                    "Multiple screens need updates without coupling",
                    "Only one screen displays scores at any time now",
                    "Direct method calls are too slow for live scores"
                ],
                correctIndex: 1,
                explanation: "An event bus lets the scoreboard, notification banner, and stats views all receive updates without knowing about each other."),
            QuizQuestion(id: "t5s_eb_2", blockType: .eventBus,
                questionText: "How should the Sports event bus handle events when the app is backgrounded?",
                options: [
                    "Continue processing all events at full speed now",
                    "Delete the event bus and recreate on foreground",
                    "Forward events directly to push notifications",
                    "Buffer events and deliver them upon foregrounding"
                ],
                correctIndex: 3,
                explanation: "Buffering events while backgrounded ensures no updates are lost, and delivering them on foreground gives the user a complete catch-up."),
            QuizQuestion(id: "t5s_eb_3", blockType: .eventBus,
                questionText: "What problem does typed event channels solve in the Sports event bus?",
                options: [
                    "They prevent subscribers from receiving wrong events",
                    "Typed channels are required by the Swift compiler",
                    "Channels make the event bus run twice as fast now",
                    "They eliminate the need for any error handling"
                ],
                correctIndex: 0,
                explanation: "Typed channels ensure a score subscriber only receives score events, not unrelated events like chat messages or ad impressions."),
        ],

        // MARK: T5 Search - MLModel (indices: 2, 0, 3)
        "t5_search_mlModel": [
            QuizQuestion(id: "t5sr_ml_1", blockType: .mlModel,
                questionText: "Why should the Search app use an ML model for query understanding?",
                options: [
                    "ML models can index database rows more quickly",
                    "Keyword matching misses semantic user intent now",
                    "String matching is not available in Swift natively",
                    "ML models eliminate the need for a search backend"
                ],
                correctIndex: 1,
                explanation: "ML-based query understanding captures semantic meaning, so 'cheap eats nearby' matches restaurants even without those exact keywords."),
            QuizQuestion(id: "t5sr_ml_2", blockType: .mlModel,
                questionText: "How should the Search ML model handle ambiguous or misspelled queries?",
                options: [
                    "Return the closest embedding match with a score",
                    "Reject the query and ask user to type it again",
                    "Auto-correct silently without telling the user",
                    "Pass the raw misspelled text to keyword search"
                ],
                correctIndex: 0,
                explanation: "Embedding-based matching finds semantically similar results even for misspelled queries, with confidence scores to rank relevance."),
            QuizQuestion(id: "t5sr_ml_3", blockType: .mlModel,
                questionText: "Why should the Search ML model run on the Neural Engine when available?",
                options: [
                    "The Neural Engine supports more model formats",
                    "CPU inference produces different numeric results",
                    "It is required by CoreML for all model types now",
                    "Neural Engine frees the CPU for UI responsiveness"
                ],
                correctIndex: 3,
                explanation: "Running inference on the Neural Engine offloads computation from the CPU, keeping the main processor free for smooth UI interactions."),
        ],

        // MARK: T5 Search - StateMachine (indices: 1, 3, 0)
        "t5_search_stateMachine": [
            QuizQuestion(id: "t5sr_sm_1", blockType: .stateMachine,
                questionText: "What states should a Search feature's state machine include at minimum?",
                options: [
                    "Only idle and loading are needed for search now",
                    "Idle, loading, results, empty, and error states",
                    "A single state that changes its inner properties",
                    "Login, search, results, and logout flow states"
                ],
                correctIndex: 1,
                explanation: "Search needs distinct states for each phase: idle (initial), loading (in-flight), results (success), empty (no matches), and error (failure)."),
            QuizQuestion(id: "t5sr_sm_2", blockType: .stateMachine,
                questionText: "Why should the Search state machine prevent transitions from error to results?",
                options: [
                    "Error and results states use the same UI layout",
                    "This transition would skip the loading indicator",
                    "Results after errors confuse debugger tooling now",
                    "It forces a retry through the loading state first"
                ],
                correctIndex: 3,
                explanation: "Requiring error -> loading -> results ensures every result comes from a fresh request, preventing stale or partial data from showing."),
            QuizQuestion(id: "t5sr_sm_3", blockType: .stateMachine,
                questionText: "How should the Search state machine handle rapid consecutive queries?",
                options: [
                    "Cancel the previous search before starting next",
                    "Queue all searches and display results in order",
                    "Block new searches until the current one finishes",
                    "Run all searches in parallel and merge the results"
                ],
                correctIndex: 0,
                explanation: "Cancelling the previous search prevents race conditions where an older query's results arrive after a newer query's results."),
        ],
    ]
}
