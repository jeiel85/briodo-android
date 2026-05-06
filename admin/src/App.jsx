import React, { useState, useEffect } from 'react';
import { onAuthStateChanged, signInWithPopup, signOut } from 'firebase/auth';
import { collection, getDocs, query, limit } from 'firebase/firestore';
import { auth, db, googleProvider } from './firebase';

// 관리자 전용 인증 Hook
function useAdminAuth() {
  const [user, setUser] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (u) => {
      setUser(u);
      if (u) {
        const idTokenResult = await u.getIdTokenResult();
        setIsAdmin(!!idTokenResult.claims.admin);
      } else {
        setIsAdmin(false);
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  const login = () => signInWithPopup(auth, googleProvider);
  const logout = () => signOut(auth);

  return { user, isAdmin, loading, login, logout };
}

const App = () => {
  const { user, isAdmin, loading, login, logout } = useAdminAuth();
  const [users, setUsers] = useState([]);
  const [fetching, setFetching] = useState(false);

  useEffect(() => {
    if (isAdmin) {
      fetchUsers();
    }
  }, [isAdmin]);

  const fetchUsers = async () => {
    setFetching(true);
    try {
      const q = query(collection(db, 'users'), limit(50));
      const querySnapshot = await getDocs(q);
      const userList = [];
      querySnapshot.forEach((doc) => {
        userList.push({ id: doc.id, ...doc.data() });
      });
      setUsers(userList);
    } catch (e) {
      console.error("Error fetching users:", e);
    } finally {
      setFetching(false);
    }
  };

  if (loading) return <div style={centerStyle}>Loading...</div>;

  if (!user) {
    return (
      <div style={centerStyle}>
        <h1>BrioDo Admin</h1>
        <button onClick={login} style={buttonStyle}>Login with Google</button>
      </div>
    );
  }

  if (!isAdmin) {
    return (
      <div style={centerStyle}>
        <h1>Access Denied</h1>
        <p>You do not have admin privileges.</p>
        <p>Logged in as: {user.email}</p>
        <button onClick={logout} style={buttonStyle}>Logout</button>
      </div>
    );
  }

  return (
    <div className="admin-dashboard" style={{ padding: '20px', background: '#f5f5f5', minHeight: '100vh', color: '#333' }}>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ margin: 0 }}>BrioDo Admin Dashboard</h1>
          <p>Welcome, {user.email}</p>
        </div>
        <button onClick={logout} style={{ ...buttonStyle, background: '#e74c3c' }}>Logout</button>
      </header>

      <section className="stats-cards" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '20px', marginBottom: '30px' }}>
        <div style={cardStyle}>
          <h3 style={{ marginTop: 0 }}>Total Users</h3>
          <p style={{ fontSize: '24px', fontWeight: 'bold', margin: 0 }}>{users.length}+</p>
        </div>
        <div style={cardStyle}>
          <h3 style={{ marginTop: 0 }}>System Status</h3>
          <p style={{ fontSize: '18px', color: '#27ae60', margin: 0 }}>● Healthy</p>
        </div>
      </section>

      <section className="user-list">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2>Recent Users</h2>
          <button onClick={fetchUsers} disabled={fetching} style={buttonStyle}>
            {fetching ? 'Refreshing...' : 'Refresh List'}
          </button>
        </div>
        <div style={{ overflowX: 'auto', marginTop: '10px' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', background: 'white', borderRadius: '8px', overflow: 'hidden' }}>
            <thead style={{ background: '#eee' }}>
              <tr>
                <th style={thStyle}>User ID</th>
                <th style={thStyle}>Last Login</th>
                <th style={thStyle}>Achievements</th>
              </tr>
            </thead>
            <tbody>
              {users.map((u) => (
                <tr key={u.id} style={{ borderBottom: '1px solid #eee' }}>
                  <td style={tdStyle}>{u.id}</td>
                  <td style={tdStyle}>{u.lastLogin?.toDate?.().toLocaleString() || 'N/A'}</td>
                  <td style={tdStyle}>{(u.achievements || []).length}</td>
                </tr>
              ))}
              {users.length === 0 && (
                <tr>
                  <td colSpan="3" style={{ ...tdStyle, textAlign: 'center' }}>No users found (Check Firestore rules)</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
};

const centerStyle = {
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  justifyContent: 'center',
  height: '100vh',
  textAlign: 'center'
};

const cardStyle = {
  background: 'white',
  padding: '20px',
  borderRadius: '12px',
  boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
};

const buttonStyle = {
  padding: '10px 20px',
  background: '#3498db',
  color: 'white',
  border: 'none',
  borderRadius: '6px',
  cursor: 'pointer',
  fontSize: '16px'
};

const thStyle = { textAlign: 'left', padding: '12px', color: '#666' };
const tdStyle = { padding: '12px', fontSize: '14px' };

export default App;
