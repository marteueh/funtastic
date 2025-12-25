@extends('layouts.app')

@section('title', 'Commissioni - FUNTASTING')

@section('content')
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-8">Le Mie Commissioni</h1>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Commissioni Totali</h3>
            <p class="text-3xl font-bold text-orange-600">€{{ number_format(auth()->user()->reseller->total_commissions ?? 0, 2) }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">In Attesa</h3>
            <p class="text-3xl font-bold text-yellow-600">€{{ number_format(auth()->user()->reseller->pending_commissions ?? 0, 2) }}</p>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Tasso Commissione</h3>
            <p class="text-3xl font-bold text-gray-900">{{ number_format((auth()->user()->reseller->commission_rate ?? 0) * 100, 1) }}%</p>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow">
        <div class="p-6 border-b border-gray-200">
            <h2 class="text-xl font-semibold text-gray-900">Storico Commissioni</h2>
        </div>
        <div class="p-6">
            <p class="text-gray-600">Nessuna commissione ancora.</p>
        </div>
    </div>
</div>
@endsection

