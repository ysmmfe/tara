import asyncio
import time
import uuid
from dataclasses import dataclass
from enum import Enum
from typing import Any, Awaitable, Callable

from .logger import get_logger

logger = get_logger("tara.jobs")


class JobStatus(str, Enum):
    pending = "pending"
    running = "running"
    done = "done"
    error = "error"


@dataclass
class Job:
    job_id: str
    status: JobStatus
    created_at: float
    updated_at: float
    result: dict | None = None
    error: str | None = None


_jobs: dict[str, Job] = {}
_lock = asyncio.Lock()
_TTL_SECONDS = 60 * 30


def _prune_expired(now: float) -> None:
    expired = [
        job_id
        for job_id, job in _jobs.items()
        if now - job.created_at > _TTL_SECONDS
    ]
    for job_id in expired:
        _jobs.pop(job_id, None)


async def create_job(
    runner: Callable[[], Awaitable[dict]],
    timeout_seconds: int,
) -> str:
    job_id = uuid.uuid4().hex
    now = time.time()
    async with _lock:
        _prune_expired(now)
        _jobs[job_id] = Job(
            job_id=job_id,
            status=JobStatus.pending,
            created_at=now,
            updated_at=now,
        )

    async def _run() -> None:
        await _update_job(job_id, status=JobStatus.running)
        try:
            result = await asyncio.wait_for(runner(), timeout=timeout_seconds)
            await _update_job(job_id, status=JobStatus.done, result=result)
        except asyncio.TimeoutError:
            await _update_job(
                job_id,
                status=JobStatus.error,
                error="Tempo limite excedido ao analisar o cardápio.",
            )
        except Exception as exc:
            logger.exception("Falha no job %s: %s", job_id, exc)
            await _update_job(
                job_id,
                status=JobStatus.error,
                error=str(exc),
            )

    asyncio.create_task(_run())
    return job_id


async def _update_job(
    job_id: str,
    *,
    status: JobStatus,
    result: dict | None = None,
    error: str | None = None,
) -> None:
    now = time.time()
    async with _lock:
        job = _jobs.get(job_id)
        if job is None:
            return
        job.status = status
        job.updated_at = now
        job.result = result
        job.error = error


async def get_job(job_id: str) -> Job | None:
    now = time.time()
    async with _lock:
        _prune_expired(now)
        return _jobs.get(job_id)
