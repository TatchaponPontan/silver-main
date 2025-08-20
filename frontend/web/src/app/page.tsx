"use client";
import React, { useState } from "react";

export default function SilverPricePage() {
  const [date, setDate] = useState("");
  const [result, setResult] = useState<null | { price: number; currency: string }>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setResult(null);
    setLoading(true);

    try {
      const res = await fetch("http://localhost:8000/api/silver", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ silver_date: date }),
      });
      const data = await res.json();
      if (data.status) {
        setResult({ price: data.price, currency: data.currency });
      } else {
        setError(data.detail ? JSON.stringify(data.detail) : data.error || "Unknown error");
      }
    } catch (err: any) {
      setError(err.message || "Network error");
    }
    setLoading(false);
  };

  return (
    <main className="flex flex-col items-center justify-center min-h-screen bg-gray-50">
      <h1 className="text-2xl font-bold mb-6">ทำนายราคาซิลเวอร์ (Silver Price Prediction)</h1>
      <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow w-full max-w-sm">
        <label htmlFor="date" className="block mb-2 font-medium">
          เลือกวันที่ (YYYY-MM-DD)
        </label>
        <input
          id="date"
          type="date"
          value={date}
          onChange={e => setDate(e.target.value)}
          className="border px-3 py-2 rounded w-full mb-4"
          required
        />
        <button
          type="submit"
          className="bg-blue-600 text-white px-4 py-2 rounded w-full"
          disabled={loading}
        >
          {loading ? "กำลังทำนาย..." : "ทำนายราคา"}
        </button>
      </form>
      {result && (
        <div className="mt-6 bg-green-100 p-4 rounded shadow">
          <div>ราคาซิลเวอร์: <span className="font-bold">{result.price}</span> {result.currency}</div>
        </div>
      )}
      {error && (
        <div className="mt-6 bg-red-100 p-4 rounded shadow text-red-700">
          {error}
        </div>
      )}
    </main>
  );
}