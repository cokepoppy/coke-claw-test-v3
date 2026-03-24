import React from 'react'
import ReactDOM from 'react-dom/client'
import './styles.css'

function App() {
  return (
    <main className="shell">
      <section className="hero">
        <p className="eyebrow">Coke Claw Demo</p>
        <h1>Welcome back</h1>
        <p className="subcopy">A lightweight login page for browser-based demos. No database is required for this sample.</p>
      </section>
      <section className="card">
        <form className="login-form">
          <label>
            <span>Email</span>
            <input type="email" placeholder="demo@cokeclaw.dev" />
          </label>
          <label>
            <span>Password</span>
            <input type="password" placeholder="Enter any password" />
          </label>
          <button type="submit">Sign in</button>
        </form>
        <div className="hint">Backend project included under <code>backend/</code> with a simple hard-coded login API.</div>
      </section>
    </main>
  )
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />)
