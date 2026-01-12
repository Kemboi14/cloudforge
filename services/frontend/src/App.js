import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
  CloudIcon,
  ServerIcon,
  ShieldCheckIcon,
  UserGroupIcon,
  CheckCircleIcon,
  ExclamationCircleIcon
} from '@heroicons/react/24/outline';

function App() {
  const [authStatus, setAuthStatus] = useState('checking');
  const [users, setUsers] = useState([]);
  const [services, setServices] = useState([
    { name: 'Auth Service', status: 'unknown', url: '/api/auth/health' },
    { name: 'Users Service', status: 'unknown', url: '/api/users/health' }
  ]);

  // Check service health
  useEffect(() => {
    const checkServices = async () => {
      const updatedServices = await Promise.all(
        services.map(async (service) => {
          try {
            const response = await axios.get(service.url);
            return { ...service, status: 'healthy' };
          } catch (error) {
            return { ...service, status: 'unhealthy' };
          }
        })
      );
      setServices(updatedServices);
    };

    checkServices();
    const interval = setInterval(checkServices, 30000); // Check every 30 seconds
    return () => clearInterval(interval);
  }, []);

  // Fetch users (simulated - would need auth token in real app)
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        // In a real app, this would include auth headers
        const response = await axios.get('/api/users/users');
        setUsers(response.data);
      } catch (error) {
        console.log('Users service not available or not authenticated');
      }
    };

    fetchUsers();
  }, []);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center">
              <CloudIcon className="h-8 w-8 text-blue-600 mr-3" />
              <h1 className="text-3xl font-bold text-gray-900">CloudForge Secure Platform</h1>
            </div>
            <div className="flex items-center space-x-2">
              <ShieldCheckIcon className="h-6 w-6 text-green-600" />
              <span className="text-sm text-gray-600">Secure Microservices</span>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Welcome Section */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 className="text-2xl font-semibold text-gray-800 mb-4">Welcome to CloudForge</h2>
          <p className="text-gray-600 mb-6">
            A cloud-native microservices platform built with Podman, Kubernetes, and Terraform.
            This platform demonstrates secure, scalable architecture for modern applications.
          </p>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="flex items-center space-x-3 p-4 bg-blue-50 rounded-lg">
              <ServerIcon className="h-8 w-8 text-blue-600" />
              <div>
                <h3 className="font-semibold text-gray-800">Container-Native</h3>
                <p className="text-sm text-gray-600">Built with Podman & Kubernetes</p>
              </div>
            </div>
            <div className="flex items-center space-x-3 p-4 bg-green-50 rounded-lg">
              <ShieldCheckIcon className="h-8 w-8 text-green-600" />
              <div>
                <h3 className="font-semibold text-gray-800">Security First</h3>
                <p className="text-sm text-gray-600">JWT authentication & authorization</p>
              </div>
            </div>
            <div className="flex items-center space-x-3 p-4 bg-purple-50 rounded-lg">
              <CloudIcon className="h-8 w-8 text-purple-600" />
              <div>
                <h3 className="font-semibold text-gray-800">Cloud Ready</h3>
                <p className="text-sm text-gray-600">Infrastructure as Code with Terraform</p>
              </div>
            </div>
          </div>
        </div>

        {/* Service Status */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <h3 className="text-xl font-semibold text-gray-800 mb-4">Service Status</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {services.map((service, index) => (
              <div key={index} className="flex items-center justify-between p-4 border rounded-lg">
                <div className="flex items-center space-x-3">
                  {service.status === 'healthy' ? (
                    <CheckCircleIcon className="h-6 w-6 text-green-600" />
                  ) : (
                    <ExclamationCircleIcon className="h-6 w-6 text-red-600" />
                  )}
                  <span className="font-medium text-gray-800">{service.name}</span>
                </div>
                <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                  service.status === 'healthy' 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-red-100 text-red-800'
                }`}>
                  {service.status}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Users Section */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-xl font-semibold text-gray-800">System Users</h3>
            <UserGroupIcon className="h-6 w-6 text-gray-600" />
          </div>
          {users.length > 0 ? (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Username
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Email
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {users.map((user) => (
                    <tr key={user.id}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {user.username}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {user.email}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          user.is_active 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-red-100 text-red-800'
                        }`}>
                          {user.is_active ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="text-center py-8 text-gray-500">
              <UserGroupIcon className="h-12 w-12 mx-auto mb-4 text-gray-400" />
              <p>User data not available. Authentication may be required.</p>
            </div>
          )}
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="text-center text-gray-500 text-sm">
            <p>CloudForge Secure Platform - Built with modern cloud-native technologies</p>
            <p className="mt-2">Powered by Podman, Kubernetes, and Terraform</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;
