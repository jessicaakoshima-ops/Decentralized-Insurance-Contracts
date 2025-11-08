(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-policy-expired (err u104))
(define-constant err-policy-not-active (err u105))
(define-constant err-claim-already-exists (err u106))
(define-constant err-claim-not-pending (err u107))
(define-constant err-invalid-amount (err u108))
(define-constant err-invalid-duration (err u109))
(define-constant err-unauthorized (err u110))

(define-map policies
  { policy-id: uint }
  {
    holder: principal,
    premium: uint,
    coverage: uint,
    start-block: uint,
    end-block: uint,
    active: bool
  }
)

(define-map claims
  { claim-id: uint }
  {
    policy-id: uint,
    claimant: principal,
    amount: uint,
    status: (string-ascii 20),
    filed-at: uint
  }
)

(define-map user-policies
  { user: principal }
  { policy-ids: (list 100 uint) }
)

(define-data-var policy-counter uint u0)
(define-data-var claim-counter uint u0)
(define-data-var pool-balance uint u0)
(define-data-var total-premiums uint u0)
(define-data-var total-payouts uint u0)

(define-public (create-policy (premium uint) (coverage uint) (duration uint))
  (let
    (
      (policy-id (+ (var-get policy-counter) u1))
      (current-block stacks-block-height)
      (end-block (+ current-block duration))
    )
    (asserts! (> premium u0) err-invalid-amount)
    (asserts! (> coverage u0) err-invalid-amount)
    (asserts! (> duration u0) err-invalid-duration)
    (asserts! (>= coverage premium) err-invalid-amount)
    (try! (stx-transfer? premium tx-sender (as-contract tx-sender)))
    (map-set policies
      { policy-id: policy-id }
      {
        holder: tx-sender,
        premium: premium,
        coverage: coverage,
        start-block: current-block,
        end-block: end-block,
        active: true
      }
    )
    (var-set policy-counter policy-id)
    (var-set pool-balance (+ (var-get pool-balance) premium))
    (var-set total-premiums (+ (var-get total-premiums) premium))
    (update-user-policies tx-sender policy-id)
    (ok policy-id)
  )
)

(define-private (update-user-policies (user principal) (policy-id uint))
  (let
    (
      (user-data (default-to { policy-ids: (list) } (map-get? user-policies { user: user })))
      (current-policies (get policy-ids user-data))
      (updated-policies (unwrap-panic (as-max-len? (append current-policies policy-id) u100)))
    )
    (map-set user-policies { user: user } { policy-ids: updated-policies })
    true
  )
)

(define-public (file-claim (policy-id uint) (claim-amount uint))
  (let
    (
      (policy (unwrap! (map-get? policies { policy-id: policy-id }) err-not-found))
      (claim-id (+ (var-get claim-counter) u1))
      (current-block stacks-block-height)
    )
    (asserts! (is-eq (get holder policy) tx-sender) err-unauthorized)
    (asserts! (get active policy) err-policy-not-active)
    (asserts! (<= current-block (get end-block policy)) err-policy-expired)
    (asserts! (> claim-amount u0) err-invalid-amount)
    (asserts! (<= claim-amount (get coverage policy)) err-invalid-amount)
    (map-set claims
      { claim-id: claim-id }
      {
        policy-id: policy-id,
        claimant: tx-sender,
        amount: claim-amount,
        status: "pending",
        filed-at: current-block
      }
    )
    (var-set claim-counter claim-id)
    (ok claim-id)
  )
)

(define-public (approve-claim (claim-id uint))
  (let
    (
      (claim (unwrap! (map-get? claims { claim-id: claim-id }) err-not-found))
      (policy (unwrap! (map-get? policies { policy-id: (get policy-id claim) }) err-not-found))
      (claim-amount (get amount claim))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-eq (get status claim) "pending") err-claim-not-pending)
    (asserts! (<= claim-amount (var-get pool-balance)) err-insufficient-funds)
    (try! (as-contract (stx-transfer? claim-amount tx-sender (get claimant claim))))
    (map-set claims
      { claim-id: claim-id }
      (merge claim { status: "approved" })
    )
    (map-set policies
      { policy-id: (get policy-id claim) }
      (merge policy { active: false })
    )
    (var-set pool-balance (- (var-get pool-balance) claim-amount))
    (var-set total-payouts (+ (var-get total-payouts) claim-amount))
    (ok true)
  )
)

(define-public (reject-claim (claim-id uint))
  (let
    (
      (claim (unwrap! (map-get? claims { claim-id: claim-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-eq (get status claim) "pending") err-claim-not-pending)
    (map-set claims
      { claim-id: claim-id }
      (merge claim { status: "rejected" })
    )
    (ok true)
  )
)

(define-public (cancel-policy (policy-id uint))
  (let
    (
      (policy (unwrap! (map-get? policies { policy-id: policy-id }) err-not-found))
    )
    (asserts! (is-eq (get holder policy) tx-sender) err-unauthorized)
    (asserts! (get active policy) err-policy-not-active)
    (map-set policies
      { policy-id: policy-id }
      (merge policy { active: false })
    )
    (ok true)
  )
)

(define-read-only (get-policy (policy-id uint))
  (ok (map-get? policies { policy-id: policy-id }))
)

(define-read-only (get-claim (claim-id uint))
  (ok (map-get? claims { claim-id: claim-id }))
)

(define-read-only (get-user-policies (user principal))
  (ok (map-get? user-policies { user: user }))
)

(define-read-only (get-pool-balance)
  (ok (var-get pool-balance))
)

(define-read-only (get-total-premiums)
  (ok (var-get total-premiums))
)

(define-read-only (get-total-payouts)
  (ok (var-get total-payouts))
)

(define-read-only (get-policy-status (policy-id uint))
  (let
    (
      (policy (unwrap! (map-get? policies { policy-id: policy-id }) err-not-found))
      (current-block stacks-block-height)
    )
    (ok {
      active: (get active policy),
      expired: (> current-block (get end-block policy)),
      blocks-remaining: (if (<= current-block (get end-block policy))
        (- (get end-block policy) current-block)
        u0
      )
    })
  )
)

(define-read-only (get-contract-stats)
  (ok {
    total-policies: (var-get policy-counter),
    total-claims: (var-get claim-counter),
    pool-balance: (var-get pool-balance),
    total-premiums: (var-get total-premiums),
    total-payouts: (var-get total-payouts)
  })
)

