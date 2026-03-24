import { API_BASE_URL } from "@/constants/api";

/**
 * ApiClient Class
 * Demonstrates: Constructor with configuration, private properties, public methods
 */
export class ApiClient {
  // Private property - only accessible within the class
  private baseURL: string;
  private defaultHeaders: HeadersInit;

  /**
   * Constructor - Initialize API client with base URL and default headers
   * @param baseURL - Base URL for API requests
   * @param headers - Optional default headers
   */
  constructor(baseURL: string, headers: HeadersInit = {}) {
    this.baseURL = baseURL;
    this.defaultHeaders = {
      "Content-Type": "application/json",
      ...headers,
    };
  }

  /**
   * Private method - Build full URL from endpoint
   */
  private buildURL(endpoint: string): string {
    return `${this.baseURL}${endpoint}`;
  }

  /**
   * Private method - Handle response and errors
   */
  private async handleResponse<T>(response: Response): Promise<T> {
    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(errorText || `API error: ${response.statusText}`);
    }

    // Handle empty responses (like DELETE)
    const contentType = response.headers.get("content-type");
    if (contentType && contentType.includes("application/json")) {
      return response.json();
    }

    return undefined as T;
  }

  /**
   * Public method - GET request
   */
  async get<T>(endpoint: string, headers?: HeadersInit): Promise<T> {
    const response = await fetch(this.buildURL(endpoint), {
      method: "GET",
      headers: { ...this.defaultHeaders, ...headers },
    });

    return this.handleResponse<T>(response);
  }

  /**
   * Public method - POST request
   */
  async post<T>(
    endpoint: string,
    data: unknown,
    headers?: HeadersInit
  ): Promise<T> {
    const response = await fetch(this.buildURL(endpoint), {
      method: "POST",
      headers: { ...this.defaultHeaders, ...headers },
      body: JSON.stringify(data),
    });

    return this.handleResponse<T>(response);
  }

  /**
   * Public method - PUT request
   */
  async put<T>(
    endpoint: string,
    data: unknown,
    headers?: HeadersInit
  ): Promise<T> {
    const response = await fetch(this.buildURL(endpoint), {
      method: "PUT",
      headers: { ...this.defaultHeaders, ...headers },
      body: JSON.stringify(data),
    });

    return this.handleResponse<T>(response);
  }

  /**
   * Public method - DELETE request
   */
  async delete(endpoint: string, headers?: HeadersInit): Promise<void> {
    const response = await fetch(this.buildURL(endpoint), {
      method: "DELETE",
      headers: { ...this.defaultHeaders, ...headers },
    });

    return this.handleResponse<void>(response);
  }

  /**
   * Public method - Update base URL
   */
  setBaseURL(newBaseURL: string): void {
    this.baseURL = newBaseURL;
  }

  /**
   * Public method - Update default headers
   */
  setDefaultHeaders(headers: HeadersInit): void {
    this.defaultHeaders = { ...this.defaultHeaders, ...headers };
  }

  /**
   * Getter - Get current base URL
   */
  get currentBaseURL(): string {
    return this.baseURL;
  }
}

// Create singleton instance for use throughout the app
export const apiClient = new ApiClient(API_BASE_URL);

// Also export the old 'api' object for backward compatibility
export const api = apiClient;
